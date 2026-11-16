#!/usr/bin/env python3
"""Regression tests for Gentoo stage3's non-verbose emerge progress."""

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from gentoo_emerge_progress import Summary, format_size


class ProgressTests(unittest.TestCase):
    def test_package_milestones_and_duplicate_suppression(self):
        summary = Summary("build-first")
        self.assertEqual(
            summary.parse(">>> Emerging (1 of 12) dev-libs/example-1.2::gentoo"),
            "1/12 dev-libs/example-1.2::gentoo: building",
        )
        self.assertIsNone(summary.parse(">>> Emerging (1 of 12) dev-libs/example-1.2::gentoo"))
        self.assertIsNone(summary.parse("src/verbose.cc:310: warning: verbose build output"))
        self.assertEqual(
            summary.parse("\x1b[32m>>> Completed (1 of 12) dev-libs/example-1.2::gentoo\x1b[0m"),
            "1/12 dev-libs/example-1.2::gentoo: completed",
        )
        self.assertEqual(
            summary.parse(">>> Emerging binary (2 of 12) dev-util/other-3.0::gentoo"),
            "2/12 dev-util/other-3.0::gentoo: installing binary",
        )
        self.assertEqual(
            summary.parse(">>> Failed to emerge (3 of 12) app-misc/bad-0.1::local"),
            "3/12 app-misc/bad-0.1::local: failed",
        )

    def test_sync_and_pretend(self):
        summary = Summary("sync-guru")
        self.assertEqual(summary.parse(">>> Syncing repository 'guru' into '/var/db/repos/guru'..."),
                         "syncing 'guru' into '/var/db/repos/guru'...")
        self.assertEqual(summary.parse("Total: 38 packages (28 new, 10 reinstalls)"),
                         "plan: 38 packages (28 new, 10 reinstalls)")
        self.assertEqual(format_size(1200), "1.2 KiB")

    def test_drains_log_when_done_marker_exists(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / "emerge.log"
            done = root / "done"
            log.write_bytes(
                b">>> Emerging (1 of 1) app-editors/vi-9.0::gentoo\r"
                b">>> Completed (1 of 1) app-editors/vi-9.0::gentoo\n"
                b"verbose output should not appear in Actions\n"
            )
            done.touch()
            process = subprocess.run(
                [sys.executable, str(Path(__file__).with_name("gentoo_emerge_progress.py")),
                 "--log", str(log), "--done", str(done), "--label", "test"],
                check=True, capture_output=True, text=True, timeout=10,
            )
            self.assertIn("1/1 app-editors/vi-9.0::gentoo: building", process.stdout)
            self.assertIn("1/1 app-editors/vi-9.0::gentoo: completed", process.stdout)
            self.assertNotIn("verbose output should not", process.stdout)


if __name__ == "__main__":
    unittest.main()
