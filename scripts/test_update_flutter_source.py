import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

import update_flutter_source as updater


class FlutterUpdaterTest(unittest.TestCase):
    def releases(self, payload, version=None):
        response = MagicMock(); response.read.return_value = json.dumps(payload).encode()
        with patch.object(updater.urllib.request, "urlopen") as open_url:
            open_url.return_value.__enter__.return_value = response
            return updater.get_flutter_release(version)

    def test_stable_release_metadata_and_manual_selection(self):
        data = {"current_release": {"stable": "stable-hash"}, "releases": [
            {"version": "3.14.0", "hash": "stable-hash", "channel": "stable"},
            {"version": "3.15.0-0.1.pre", "hash": "beta", "channel": "beta"},
        ]}
        self.assertEqual(self.releases(data)["version"], "3.14.0")
        self.assertEqual(self.releases(data, "3.14.0")["hash"], "stable-hash")

    def test_stable_release_metadata_rejects_incomplete_or_prerelease(self):
        cases = (
            {"current_release": {"stable": "h"}, "releases": [{"hash": "h", "channel": "stable"}]},
            {"current_release": {"stable": "h"}, "releases": [{"version": "3.14.0", "hash": "h", "channel": "beta"}]},
            {"current_release": {"stable": "h"}, "releases": [{"version": "3.14.0", "channel": "stable", "hash": "h"}]},
        )
        with self.assertRaises(ValueError): self.releases(cases[0])
        with self.assertRaises(ValueError): self.releases(cases[1], "3.14.0")
        self.assertEqual(self.releases(cases[2], "3.14.0")["hash"], "h")
        with self.assertRaises(ValueError): self.releases(cases[2], "3.15.0-0.1.pre")

    def test_manual_ref_must_match_authoritative_stable_hash(self):
        release = {"version": "3.14.0", "hash": "authoritative", "channel": "stable"}
        with patch.object(updater, "get_flutter_release", return_value=release), patch.object(sys, "argv", ["updater", "--version", "3.14.0", "--ref", "wrong"]):
            with self.assertRaises(SystemExit): updater.main()

    def test_dart_constraint_evaluator(self):
        for version, expected in (("3.10.9", False), ("3.11.0", True), ("3.13.9-r1", True), ("4.0.0", False)):
            self.assertEqual(updater.evaluate_dart_constraint("^3.11.0-0", version), expected)
        for version, expected in (("3.1.9", False), ("3.2.0", True), ("3.99.0", True), ("4.0.0", False)):
            self.assertEqual(updater.evaluate_dart_constraint(">=3.2.0-0 <4.0.0", version), expected)
        self.assertFalse(updater.evaluate_dart_constraint("wat", "3.11.0"))
        self.assertFalse(updater.evaluate_dart_constraint("^3.bad.0", "3.11.0"))

    @patch.object(updater, "run_cmd")
    def test_pending_dart_run_is_version_specific(self, run):
        run.return_value = subprocess.CompletedProcess([], 0, json.dumps([
            {"status": "in_progress", "displayTitle": "Dart source update (3.13.0)", "url": "old"},
            {"status": "queued", "displayTitle": "Dart source update (3.14.0)", "url": "match"},
        ]))
        self.assertEqual(updater.pending_dart_update_run("3.14.0")["url"], "match")
        self.assertIsNone(updater.pending_dart_update_run("3.15.0"))

    @patch.object(updater, "run_cmd")
    def test_prerequisite_dispatch_dedup_and_failure_matrix(self, run):
        cp = lambda output="", rc=0: subprocess.CompletedProcess([], rc, output)
        # Existing prerequisite PR: report it and do not dispatch.
        run.side_effect = [cp('[{"url":"https://example/pr"}]')]
        self.assertIn("existing prerequisite PR", updater.dispatch_dart_prerequisite("3.14.0"))
        self.assertFalse(any("workflow" in c.args[0] for c in run.call_args_list))
        # Lookup failure is fatal, never a reason to dispatch.
        run.reset_mock(); run.side_effect = subprocess.CalledProcessError(1, "gh")
        with self.assertRaises(subprocess.CalledProcessError): updater.dispatch_dart_prerequisite("3.14.0")
        # A remote branch with no PR is a recovery state, not completion.
        run.reset_mock(); run.side_effect = [cp("[]"), cp("", 0)]
        self.assertIn("stranded prerequisite branch", updater.dispatch_dart_prerequisite("3.14.0"))
        # Matching pending run defers; an unrelated version does not.
        run.reset_mock(); run.side_effect = [cp("[]"), cp("", 2), cp('[{"status":"queued","displayTitle":"Dart source update (3.14.0)","url":"match"}]')]
        self.assertIn("pending prerequisite workflow", updater.dispatch_dart_prerequisite("3.14.0"))
        run.reset_mock(); run.side_effect = [cp("[]"), cp("", 2), cp('[{"status":"queued","displayTitle":"Dart source update (3.13.0)","url":"other"}]'), cp(), cp("[]")]
        self.assertIn("dispatched prerequisite workflow", updater.dispatch_dart_prerequisite("3.14.0"))
        dispatched = [c for c in run.call_args_list if c.args[0][:3] == ["gh", "workflow", "run"]]
        self.assertEqual(len(dispatched), 1)
        # Dispatch failure is fatal.
        run.reset_mock(); run.side_effect = [cp("[]"), cp("", 2), cp("[]"), subprocess.CalledProcessError(1, "gh")]
        with self.assertRaises(subprocess.CalledProcessError): updater.dispatch_dart_prerequisite("3.14.0")

    @patch.object(updater, "run_cmd")
    def test_branch_pr_and_superseding_fail_closed_or_correct(self, run):
        run.return_value = subprocess.CompletedProcess([], 128, "")
        with self.assertRaises(SystemExit): updater.check_branch_exists("x")
        run.return_value = subprocess.CompletedProcess([], 0, json.dumps([
            {"headRefName": "auto-update-flutter-source-3.13.0", "url": "old"},
            {"headRefName": "auto-update-flutter-source-3.15.0", "url": "new"},
        ]))
        self.assertTrue(updater.check_superseding_release("flutter-source", "3.14.0"))
        updater.close_superseding_releases("flutter-source", "3.14.0")
        self.assertTrue(any(c.args[0][:4] == ["gh", "pr", "close", "auto-update-flutter-source-3.13.0"] for c in run.call_args_list))

    @patch.object(updater, "close_superseding_releases")
    @patch.object(updater, "run_cmd")
    def test_pr_creation_success_and_failure_after_push(self, run, close):
        run.side_effect = lambda cmd, **kwargs: subprocess.CompletedProcess(cmd, 0, "M x\n" if cmd[:3] == ["git", "status", "--porcelain"] else "")
        updater.commit_and_push("branch", "3.13.3", "3.14.0", "release-hash", "engine", "dart", "fonts", "gradle", "^3.11.0", False)
        pr = next(c.args[0] for c in run.call_args_list if c.args[0][:3] == ["gh", "pr", "create"])
        body = pr[pr.index("--body") + 1]
        self.assertIn("Old Packaged Version:** 3.13.3", body)
        self.assertIn("Authoritative Revision:** release-hash", body)
        self.assertIn("Flutter Engine revision:** engine", body)
        self.assertIn("Pinned Dart revision:** dart", body)
        close.assert_called_once()
        def fail(cmd, **kwargs):
            if cmd[:3] == ["git", "status", "--porcelain"]: return subprocess.CompletedProcess(cmd, 0, "M x\n")
            if cmd[:3] == ["gh", "pr", "create"]: raise subprocess.CalledProcessError(1, cmd)
            return subprocess.CompletedProcess(cmd, 0, "")
        run.reset_mock(); run.side_effect = fail
        with self.assertRaises(subprocess.CalledProcessError):
            updater.commit_and_push("branch", "3.13.3", "3.14.0", "h", "e", "d", "f", "g", "c", False)
        self.assertTrue(any(c.args[0][:3] == ["git", "push", "origin"] for c in run.call_args_list))

    def make_repo(self, root):
        for directory, filename in (("dev-libs/flutter-engine", "flutter-engine-3.13.3.ebuild"), ("dev-lang/flutter", "flutter-3.13.3.ebuild"), ("virtual/flutter", "flutter-3.13.3.ebuild"), ("dev-lang/dart", "dart-3.13.3.ebuild")):
            path = root / directory; path.mkdir(parents=True, exist_ok=True)
            (path / filename).write_text('EAPI=8\nSRC_URI="https://example.invalid/a.tar.xz"\n')
        subprocess.run(["git", "init", "-q"], cwd=root, check=True); subprocess.run(["git", "add", "."], cwd=root, check=True)
        subprocess.run(["git", "-c", "commit.gpgsign=false", "-c", "user.email=t@example", "-c", "user.name=t", "commit", "-qm", "base"], cwd=root, check=True)

    def test_flutter_dry_run_real_git_repo_is_immutable_and_generates_coordinated_tree(self):
        checkout_targets = [Path(updater.REPO_ROOT) / p for p in ("dev-lang/flutter/flutter-3.24.4.ebuild", "dev-libs/flutter-engine/flutter-engine-3.24.4.ebuild")]
        self.assertFalse(any(p.exists() for p in checkout_targets))
        with tempfile.TemporaryDirectory() as td:
            root = Path(td); self.make_repo(root)
            staged, unstaged, untracked = root / "staged", root / "unstaged", root / "untracked"
            staged.write_text("staged\n"); subprocess.run(["git", "add", "staged"], cwd=root, check=True)
            unstaged.write_text("before\n"); subprocess.run(["git", "add", "unstaged"], cwd=root, check=True); unstaged.write_text("after\n"); untracked.write_text("untracked\n")
            status = subprocess.check_output(["git", "status", "--porcelain=v1"], cwd=root); generated = []
            def command(cmd, **kwargs):
                joined = " ".join(cmd)
                if "generate_flutter_" in joined:
                    target = Path(cmd[cmd.index("--ebuild") + 1]); target.write_text(target.read_text() + "# generated\n"); generated.append(target)
                if "verify_manifest.py" in joined:
                    for directory in map(Path, cmd[2:]): (directory / "Manifest").write_text("DIST fixture 1 BLAKE2B dead SHA512 beef\n"); generated.append(directory / "Manifest")
                return subprocess.CompletedProcess(cmd, 0, "")
            release = {"version": "3.24.4", "hash": "release", "channel": "stable"}
            with patch.object(updater, "REPO_ROOT", root), patch.object(updater, "get_flutter_release", return_value=release), patch.object(updater, "check_branch_exists", return_value=False), patch.object(updater, "check_pr_exists", return_value=False), patch.object(updater, "check_superseding_release", return_value=False), patch.object(updater, "get_flutter_internal_version", side_effect=["engine", "fonts", "gradle"]), patch.object(updater, "check_dart_compatibility", return_value="^3.11.0-0"), patch.object(updater.urllib.request, "urlopen") as urlopen, patch.object(updater, "run_cmd", side_effect=command), patch.object(sys, "argv", ["updater", "--dry-run"]):
                response = MagicMock(); response.read.return_value = b"'dart_revision': 'deadbeef'"; urlopen.return_value.__enter__.return_value = response
                self.assertEqual(updater.main(), 0)
            self.assertGreaterEqual(len(generated), 4); self.assertEqual(subprocess.check_output(["git", "status", "--porcelain=v1"], cwd=root), status)
            self.assertEqual((staged).read_text(), "staged\n"); self.assertEqual(unstaged.read_text(), "after\n"); self.assertEqual(untracked.read_text(), "untracked\n")
        self.assertFalse(any(p.exists() for p in checkout_targets))


if __name__ == "__main__":
    unittest.main()
