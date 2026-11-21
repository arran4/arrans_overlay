"""Regression coverage for manifest verification PR lifecycle."""
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

WORKFLOW = (Path(__file__).resolve().parents[1]
            / ".github/workflows/verify-manifests.yml").read_text()


class TestVerifyManifestsWorkflow(unittest.TestCase):
    def test_never_closes_or_replaces_original_pr(self):
        self.assertNotIn("gh pr close", WORKFLOW)
        self.assertNotIn("Close superseded pull request", WORKFLOW)
        self.assertNotIn("Superseded by", WORKFLOW)
        self.assertNotIn("github.head_ref", WORKFLOW)

    def test_only_default_branch_push_can_create_repair_pr(self):
        push = WORKFLOW.split("  push:\n", 1)[1].split("  pull_request:", 1)[0]
        self.assertIn("branches:\n      - main", push)
        repair = WORKFLOW.split("      - name: Create Pull Request\n", 1)[1]
        self.assertIn("if: github.event_name == 'push' && github.ref_name == github.event.repository.default_branch && steps.changed-files.outputs.dirs != ''", repair)
        self.assertIn("base: ${{ github.event.repository.default_branch }}", repair)
        self.assertIn("uses: peter-evans/create-pull-request@", repair)

    def test_verified_pr_passes_and_stale_pr_fails(self):
        step = WORKFLOW.split("      - name: Reject stale Manifests on pull requests\n", 1)[1]
        self.assertIn("if: github.event_name == 'pull_request' && steps.changed-files.outputs.dirs != ''", step)
        self.assertLess(WORKFLOW.index("id: verify\n"), WORKFLOW.index("Reject stale Manifests"))
        body = re.search(r"        run: \|\n((?:          [^\n]*\n)+)", step)
        self.assertIsNotNone(body)
        script = "\n".join(line[10:] for line in body.group(1).splitlines())
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            def git(*args):
                subprocess.run(["git", *args], cwd=repo, check=True, capture_output=True)
            git("init", "-q")
            git("config", "user.name", "CI")
            git("config", "user.email", "ci@example.invalid")
            manifest = repo / "app-admin/sos/Manifest"
            manifest.parent.mkdir(parents=True)
            manifest.write_text("DIST sos.tar.gz 42\n")
            git("add", ".")
            git("commit", "-qm", "seed")
            def check():
                return subprocess.run(["bash", "-e", "-c", script], cwd=repo,
                                      text=True, capture_output=True)
            self.assertEqual(check().returncode, 0)
            manifest.write_text("DIST sos.tar.gz 43\n")
            failed = check()
            self.assertEqual(failed.returncode, 1)
            self.assertIn("Regenerate the affected Manifests", failed.stdout)
            self.assertIn("+DIST sos.tar.gz 43", failed.stdout)
            self.assertEqual(manifest.read_text(), "DIST sos.tar.gz 43\n")
            git("add", ".")
            git("commit", "-qm", "repair")
            self.assertEqual(check().returncode, 0)


if __name__ == "__main__":
    unittest.main()
