#!/usr/bin/env python3
import os
import shutil
import tempfile
import subprocess
import unittest

class TestManifestRestore(unittest.TestCase):
    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.repo_dir = os.path.join(self.test_dir, 'repo')
        self.snapshot_dir = os.path.join(self.test_dir, 'snapshot')
        os.makedirs(self.repo_dir)
        os.makedirs(self.snapshot_dir)

    def tearDown(self):
        shutil.rmtree(self.test_dir)

    def _setup_mock_structure(self):
        # Create mock repository structure
        os.makedirs(os.path.join(self.repo_dir, 'app-misc', 'pkg-no-change'))
        os.makedirs(os.path.join(self.repo_dir, 'app-misc', 'pkg-diff'))
        os.makedirs(os.path.join(self.repo_dir, 'app-misc', 'pkg-deleted'))

        with open(os.path.join(self.repo_dir, 'app-misc', 'pkg-no-change', 'Manifest'), 'w') as f: f.write("same")
        with open(os.path.join(self.repo_dir, 'app-misc', 'pkg-diff', 'Manifest'), 'w') as f: f.write("same")
        with open(os.path.join(self.repo_dir, 'app-misc', 'pkg-deleted', 'Manifest'), 'w') as f: f.write("same")

        # Create mock snapshot
        os.makedirs(os.path.join(self.snapshot_dir, 'app-misc', 'pkg-no-change'))
        os.makedirs(os.path.join(self.snapshot_dir, 'app-misc', 'pkg-diff'))
        os.makedirs(os.path.join(self.snapshot_dir, 'app-misc', 'pkg-deleted'))
        os.makedirs(os.path.join(self.snapshot_dir, 'app-misc', 'pkg-dedupe-failed'))

        with open(os.path.join(self.snapshot_dir, 'app-misc', 'pkg-no-change', 'Manifest'), 'w') as f: f.write("same")
        with open(os.path.join(self.snapshot_dir, 'app-misc', 'pkg-diff', 'Manifest'), 'w') as f: f.write("original")
        with open(os.path.join(self.snapshot_dir, 'app-misc', 'pkg-deleted', 'Manifest'), 'w') as f: f.write("same")
        with open(os.path.join(self.snapshot_dir, 'app-misc', 'pkg-dedupe-failed', 'Manifest'), 'w') as f: f.write("same")

    def _simulate_dedupe(self):
        # Simulate dedupe behavior
        with open(os.path.join(self.repo_dir, 'app-misc', 'pkg-diff', 'Manifest'), 'w') as f: f.write("modified")
        shutil.rmtree(os.path.join(self.repo_dir, 'app-misc', 'pkg-deleted'))
        os.makedirs(os.path.join(self.repo_dir, 'app-misc', 'pkg-added'))
        with open(os.path.join(self.repo_dir, 'app-misc', 'pkg-added', 'Manifest'), 'w') as f: f.write("new")

    def _run_check(self):
        # Extract the relevant block from scheduled-daily-tasks.yml
        yaml_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.github', 'workflows', 'scheduled-daily-tasks.yml')
        with open(yaml_path, 'r') as f:
            lines = f.readlines()

        # We find the specific block starting with "# Verify exact-byte preservation without relying on git"
        start_idx = -1
        end_idx = -1
        for i, line in enumerate(lines):
            if "Verify exact-byte preservation without relying on git" in line:
                start_idx = i
            if start_idx != -1 and "cd \"$GITHUB_WORKSPACE\"" in line:
                end_idx = i
                break

        if start_idx == -1 or end_idx == -1:
            raise ValueError("Could not find the check script in scheduled-daily-tasks.yml")

        script_lines = []
        for line in lines[start_idx:end_idx+1]:
            # remove the leading 10 spaces
            script_lines.append(line[10:])

        script = "set -euo pipefail\n" + "".join(script_lines)

        # Replace the hardcoded /tmp/manifest-snapshot and $GITHUB_WORKSPACE with our test dirs
        script = script.replace("/tmp/manifest-snapshot", self.snapshot_dir)
        script = f"GITHUB_WORKSPACE={self.repo_dir}\n" + script

        try:
            proc = subprocess.run(script, shell=True, text=True, executable='/bin/bash', cwd=self.repo_dir, capture_output=True, check=True)
            return True, proc.stderr
        except subprocess.CalledProcessError as e:
            return False, e.stderr

    def test_manifest_restoration(self):
        self._setup_mock_structure()
        self._simulate_dedupe()

        success, stderr = self._run_check()
        self.assertFalse(success)
        self.assertIn("Refusing to continue: dedupe left Manifest changes after restoration: app-misc/pkg-diff/Manifest", stderr)
        self.assertIn("Refusing to continue: dedupe added new Manifest file: app-misc/pkg-added/Manifest", stderr)
        self.assertIn("Refusing to continue: dedupe deleted Manifest file: app-misc/pkg-deleted/Manifest", stderr)
        self.assertIn("Refusing to continue: dedupe deleted Manifest file: app-misc/pkg-dedupe-failed/Manifest", stderr)
        self.assertNotIn("app-misc/pkg-no-change", stderr)

if __name__ == '__main__':
    unittest.main()
