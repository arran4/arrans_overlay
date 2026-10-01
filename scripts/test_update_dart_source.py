from pathlib import Path
import unittest
from unittest.mock import patch, mock_open, MagicMock
import update_dart_source as update_dart_source
import subprocess
from pathlib import Path

class TestUpdateDartSource(unittest.TestCase):
    @patch('update_dart_source.urllib.request.urlopen')
    def test_get_latest_dart_version(self, mock_urlopen):
        mock_response = MagicMock()
        mock_response.read.return_value = b'{"version": "3.14.0", "revision": "abc"}'
        mock_urlopen.return_value.__enter__.return_value = mock_response
        self.assertEqual(update_dart_source.get_latest_dart_version(), "3.14.0")


    @patch('scripts.update_dart_source.run_cmd')
    @patch('scripts.update_dart_source.check_branch_exists')
    @patch('scripts.update_dart_source.check_pr_exists')
    @patch('scripts.update_dart_source.check_superseding_release')
    @patch('scripts.update_dart_source.ebuild_exists')
    @patch('scripts.update_dart_source.get_dart_release')
    def test_main_lifecycle(self, mock_get_rel, mock_ebuild_exists, mock_super, mock_pr, mock_branch, mock_run_cmd):
        from scripts import update_dart_source
        import sys

        mock_get_rel.return_value = {"version": "3.5.4", "revision": "abcdef"}
        mock_ebuild_exists.return_value = True

        # Test no-op if packaged
        with patch('sys.argv', ['update_dart_source.py']):
            self.assertEqual(update_dart_source.main(), 0)

        mock_ebuild_exists.return_value = False
        mock_branch.return_value = True
        mock_pr.return_value = False

        # Test branch recovery failure
        with patch('sys.argv', ['update_dart_source.py']):
            with self.assertRaises(SystemExit):
                update_dart_source.main()

        # Test dedup
        mock_branch.return_value = True
        mock_pr.return_value = True
        with patch('sys.argv', ['update_dart_source.py']):
            self.assertEqual(update_dart_source.main(), 0)


    def test_dart_version_sorting(self):
        from scripts import update_dart_source
        self.assertEqual(update_dart_source.compare_versions("3.9.0", "3.10.0"), -1)
        self.assertEqual(update_dart_source.compare_versions("3.13.3", "3.13.3-r1"), -1)
        self.assertEqual(update_dart_source.compare_versions("3.13.3-r1", "3.13.3-r10"), -1)
        self.assertEqual(update_dart_source.compare_versions("3.13.3-r10", "3.13.3-r1"), 1)
        self.assertEqual(update_dart_source.compare_versions("3.13.3-r10", "3.13.3-r10"), 0)

    @patch('update_dart_source.REPO_ROOT', Path("/fake/root"))
    @patch('pathlib.Path.exists', return_value=True)
    @patch('pathlib.Path.glob', return_value=[Path("/fake/root/dev-lang/dart/dart-3.14.0.ebuild")])
    def test_ebuild_exists(self, mock_glob, mock_exists):
        self.assertTrue(update_dart_source.ebuild_exists("3.14.0", Path("/tmp")))


    @patch('scripts.update_dart_source.run_cmd')
    @patch('scripts.update_dart_source.check_branch_exists')
    @patch('scripts.update_dart_source.check_pr_exists')
    @patch('scripts.update_dart_source.check_superseding_release')
    @patch('scripts.update_dart_source.ebuild_exists')
    @patch('scripts.update_dart_source.get_dart_release')
    def test_main_lifecycle(self, mock_get_rel, mock_ebuild_exists, mock_super, mock_pr, mock_branch, mock_run_cmd):
        from scripts import update_dart_source
        import sys

        mock_get_rel.return_value = {"version": "3.5.4", "revision": "abcdef"}
        mock_ebuild_exists.return_value = True

        # Test no-op if packaged
        with patch('sys.argv', ['update_dart_source.py']):
            self.assertEqual(update_dart_source.main(), 0)

        mock_ebuild_exists.return_value = False
        mock_branch.return_value = True
        mock_pr.return_value = False

        # Test branch recovery failure
        with patch('sys.argv', ['update_dart_source.py']):
            with self.assertRaises(SystemExit):
                update_dart_source.main()

        # Test dedup
        mock_branch.return_value = True
        mock_pr.return_value = True
        with patch('sys.argv', ['update_dart_source.py']):
            self.assertEqual(update_dart_source.main(), 0)


    def test_dart_version_sorting(self):
        from scripts import update_dart_source
        self.assertEqual(update_dart_source.compare_versions("3.9.0", "3.10.0"), -1)
        self.assertEqual(update_dart_source.compare_versions("3.13.3", "3.13.3-r1"), -1)
        self.assertEqual(update_dart_source.compare_versions("3.13.3-r1", "3.13.3-r10"), -1)
        self.assertEqual(update_dart_source.compare_versions("3.13.3-r10", "3.13.3-r1"), 1)
        self.assertEqual(update_dart_source.compare_versions("3.13.3-r10", "3.13.3-r10"), 0)

    @patch('update_dart_source.REPO_ROOT', Path("/fake/root"))
    @patch('pathlib.Path.exists', return_value=True)
    @patch('pathlib.Path.glob', return_value=[])
    def test_ebuild_not_exists(self, mock_glob, mock_exists):
        self.assertFalse(update_dart_source.ebuild_exists("3.14.0", Path("/tmp")))

    @patch('update_dart_source.run_cmd')
    def test_check_branch_exists(self, mock_run_cmd):
        mock_run_cmd.return_value.returncode = 0
        self.assertTrue(update_dart_source.check_branch_exists("my-branch"))

        mock_run_cmd.return_value.returncode = 2
        self.assertFalse(update_dart_source.check_branch_exists("my-branch"))

        mock_run_cmd.return_value.returncode = 128
        with self.assertRaises(SystemExit):
            update_dart_source.check_branch_exists("my-branch")

    @patch('update_dart_source.run_cmd')
    def test_check_pr_exists(self, mock_run_cmd):
        mock_run_cmd.return_value.stdout = '[{"url": "http://pr"}]'
        self.assertTrue(update_dart_source.check_pr_exists("my-branch"))

        mock_run_cmd.return_value.stdout = '[]'
        self.assertFalse(update_dart_source.check_pr_exists("my-branch"))

        mock_run_cmd.side_effect = subprocess.CalledProcessError(1, 'gh')
        with self.assertRaises(subprocess.CalledProcessError):
            update_dart_source.check_pr_exists("my-branch")

        mock_run_cmd.side_effect = FileNotFoundError()
        with self.assertRaises(SystemExit):
            update_dart_source.check_pr_exists("my-branch")

if __name__ == '__main__':
    unittest.main()
