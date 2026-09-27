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

    @patch('update_dart_source.REPO_ROOT', Path("/fake/root"))
    @patch('pathlib.Path.exists', return_value=True)
    @patch('pathlib.Path.glob', return_value=[Path("/fake/root/dev-lang/dart/dart-3.14.0.ebuild")])
    def test_ebuild_exists(self, mock_glob, mock_exists):
        self.assertTrue(update_dart_source.ebuild_exists("3.14.0"))

    @patch('update_dart_source.REPO_ROOT', Path("/fake/root"))
    @patch('pathlib.Path.exists', return_value=True)
    @patch('pathlib.Path.glob', return_value=[])
    def test_ebuild_not_exists(self, mock_glob, mock_exists):
        self.assertFalse(update_dart_source.ebuild_exists("3.14.0"))

    @patch('update_dart_source.run_cmd')
    def test_check_branch_exists(self, mock_run_cmd):
        mock_run_cmd.return_value.stdout = ""
        self.assertTrue(update_dart_source.check_branch_exists("my-branch"))

        mock_run_cmd.side_effect = subprocess.CalledProcessError(1, 'git')
        self.assertFalse(update_dart_source.check_branch_exists("my-branch"))

    @patch('update_dart_source.run_cmd')
    def test_check_pr_exists(self, mock_run_cmd):
        mock_run_cmd.return_value.stdout = '[{"url": "http://pr"}]'
        self.assertTrue(update_dart_source.check_pr_exists("my-branch"))

        mock_run_cmd.return_value.stdout = '[]'
        self.assertFalse(update_dart_source.check_pr_exists("my-branch"))

        mock_run_cmd.side_effect = subprocess.CalledProcessError(1, 'gh')
        self.assertFalse(update_dart_source.check_pr_exists("my-branch"))

if __name__ == '__main__':
    unittest.main()
