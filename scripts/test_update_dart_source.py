import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

import update_dart_source as updater


class DartUpdaterTest(unittest.TestCase):
    def metadata(self, payload, requested=None):
        response = MagicMock()
        response.read.return_value = json.dumps(payload).encode()
        with patch.object(updater.urllib.request, "urlopen") as open_url:
            open_url.return_value.__enter__.return_value = response
            return updater.get_dart_release(requested)

    def test_release_metadata_valid_requested_and_latest(self):
        self.assertEqual(self.metadata({"version": "3.14.0", "revision": "abc"}, "3.14.0")["revision"], "abc")
        self.assertEqual(self.metadata({"version": "3.14.1", "revision": "def"})["version"], "3.14.1")

    def test_release_metadata_rejects_bad_records(self):
        for payload, requested, message in (
            ({"version": "3.14.1", "revision": "a"}, "3.14.0", "Requested Dart version"),
            ({"version": "3.14.0"}, None, "missing revision"),
            ({"revision": "a"}, None, "parse version"),
        ):
            with self.subTest(payload=payload):
                with self.assertRaisesRegex(ValueError, message):
                    self.metadata(payload, requested)
        response = MagicMock()
        response.read.return_value = b"not-json"
        with patch.object(updater.urllib.request, "urlopen") as open_url:
            open_url.return_value.__enter__.return_value = response
            with self.assertRaises(ValueError):
                updater.get_dart_release()

    def test_explicit_ref_must_match_authoritative_dart_revision(self):
        with patch.object(updater, "get_dart_release", return_value={"version": "3.14.0", "revision": "authoritative"}), patch.object(sys, "argv", ["updater", "--version", "3.14.0", "--ref", "wrong"]):
            with self.assertRaises(SystemExit):
                updater.main()

    @patch.object(updater, "run_cmd")
    def test_branch_and_pr_lookup_fail_closed(self, run):
        run.return_value = subprocess.CompletedProcess([], 128, "")
        with self.assertRaises(SystemExit):
            updater.check_branch_exists("x")
        run.side_effect = subprocess.CalledProcessError(1, "gh")
        with self.assertRaises(subprocess.CalledProcessError):
            updater.check_pr_exists("x")

    @patch.object(updater, "run_cmd")
    def test_superseding_only_newer_blocks_and_only_older_closes(self, run):
        run.return_value = subprocess.CompletedProcess([], 0, json.dumps([
            {"headRefName": "auto-update-dart-source-3.13.0", "url": "old"},
            {"headRefName": "auto-update-dart-source-3.15.0", "url": "new"},
            {"headRefName": "other", "url": "other"},
        ]))
        self.assertTrue(updater.check_superseding_release("dart-source", "3.14.0"))
        self.assertFalse(updater.check_superseding_release("dart-source", "3.16.0"))
        updater.close_superseding_releases("dart-source", "3.14.0")
        closes = [c.args[0] for c in run.call_args_list if c.args[0][:3] == ["gh", "pr", "close"]]
        self.assertEqual(closes, [["gh", "pr", "close", "auto-update-dart-source-3.13.0", "--comment", "Superseded by 3.14.0"]])

    def test_virtual_provider_policy_preserves_existing_constraints(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            virtual = root / "virtual/dart"
            virtual.mkdir(parents=True)
            existing = virtual / "dart-3.13.0.ebuild"
            existing.write_text("RDEPEND=\"|| ( =dev-lang/dart-bin-3.13.0 )\"\n")
            updater.create_virtual_dart("3.14.0", root)
            self.assertEqual(existing.read_text(), "RDEPEND=\"|| ( =dev-lang/dart-bin-3.13.0 )\"\n")
            self.assertFalse((virtual / "dart-3.14.0.ebuild").exists())

    @patch.object(updater, "close_superseding_releases")
    @patch.object(updater, "run_cmd")
    def test_pr_creation_boundary_and_body(self, run, close):
        run.side_effect = lambda cmd, **kwargs: subprocess.CompletedProcess(cmd, 0, "M x\n" if cmd[:3] == ["git", "status", "--porcelain"] else "")
        updater.commit_and_push("branch", "3.13.3-r1", "3.14.0", "revision-14", False)
        pr = next(c.args[0] for c in run.call_args_list if c.args[0][:3] == ["gh", "pr", "create"])
        body = pr[pr.index("--body") + 1]
        self.assertIn("Old Packaged Version:** 3.13.3-r1", body)
        self.assertIn("Authoritative Revision:** revision-14", body)
        self.assertIn("Virtual-provider decision", body)
        close.assert_called_once()

    @patch.object(updater, "run_cmd")
    def test_pr_create_failure_after_push_is_fatal(self, run):
        def command(cmd, **kwargs):
            if cmd[:3] == ["git", "status", "--porcelain"]:
                return subprocess.CompletedProcess(cmd, 0, "M x\n")
            if cmd[:3] == ["gh", "pr", "create"]:
                raise subprocess.CalledProcessError(1, cmd)
            return subprocess.CompletedProcess(cmd, 0, "")
        run.side_effect = command
        with self.assertRaises(subprocess.CalledProcessError):
            updater.commit_and_push("branch", "3.13.3", "3.14.0", "r", False)
        self.assertTrue(any(c.args[0][:3] == ["git", "push", "origin"] for c in run.call_args_list))

    def make_repo(self, root):
        for directory, filename in (("dev-lang/dart", "dart-3.13.3.ebuild"), ("virtual/dart", "dart-3.13.3.ebuild")):
            path = root / directory
            path.mkdir(parents=True, exist_ok=True)
            (path / filename).write_text('EAPI=8\nSRC_URI="https://example.invalid/source.tar.xz"\n')
        subprocess.run(["git", "init", "-q"], cwd=root, check=True)
        subprocess.run(["git", "add", "."], cwd=root, check=True)
        subprocess.run(["git", "-c", "commit.gpgsign=false", "-c", "user.email=t@example", "-c", "user.name=t", "commit", "-qm", "base"], cwd=root, check=True)

    def test_dry_run_real_git_repo_is_immutable_and_generates_isolated_tree(self):
        checkout_target = Path(updater.REPO_ROOT) / "dev-lang/dart/dart-3.5.4.ebuild"
        self.assertFalse(checkout_target.exists())
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self.make_repo(root)
            staged, unstaged, untracked = root / "staged", root / "unstaged", root / "untracked"
            staged.write_text("staged\n"); subprocess.run(["git", "add", "staged"], cwd=root, check=True)
            unstaged.write_text("before\n"); subprocess.run(["git", "add", "unstaged"], cwd=root, check=True); unstaged.write_text("after\n")
            untracked.write_text("untracked\n")
            before_status = subprocess.check_output(["git", "status", "--porcelain=v1"], cwd=root)
            generated = []
            def command(cmd, **kwargs):
                if "generate_dart_ebuild.py" in " ".join(cmd):
                    target = Path(cmd[cmd.index("--ebuild") + 1]); target.write_text(target.read_text() + "# generated\n"); generated.append(target)
                if "verify_manifest.py" in " ".join(cmd):
                    target = Path(cmd[-1]); (target / "Manifest").write_text("DIST fixture 1 BLAKE2B dead SHA512 beef\n"); generated.append(target / "Manifest")
                return subprocess.CompletedProcess(cmd, 0, "")
            with patch.object(updater, "REPO_ROOT", root), patch.object(updater, "get_dart_release", return_value={"version": "3.5.4", "revision": "r"}), patch.object(updater, "check_branch_exists", return_value=False), patch.object(updater, "check_pr_exists", return_value=False), patch.object(updater, "check_superseding_release", return_value=False), patch.object(updater, "run_cmd", side_effect=command), patch.object(sys, "argv", ["updater", "--dry-run"]):
                self.assertEqual(updater.main(), 0)
            self.assertTrue(generated)
            self.assertEqual(subprocess.check_output(["git", "status", "--porcelain=v1"], cwd=root), before_status)
            self.assertEqual(staged.read_text(), "staged\n")
            self.assertEqual(unstaged.read_text(), "after\n")
            self.assertEqual(untracked.read_text(), "untracked\n")
        self.assertFalse(checkout_target.exists())


if __name__ == "__main__":
    unittest.main()
