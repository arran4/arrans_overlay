import unittest
from unittest.mock import patch, MagicMock
import update_flutter_source as update_flutter_source
from pathlib import Path
import subprocess

class TestUpdateFlutterSource(unittest.TestCase):
    @patch('update_flutter_source.urllib.request.urlopen')
    def test_get_latest_flutter_version(self, mock_urlopen):
        mock_response = MagicMock()
        mock_response.read.return_value = b'{"current_release": {"stable": "hash123"}, "releases": [{"channel": "stable", "version": "3.24.4", "hash": "hash123"}, {"channel": "beta", "version": "3.25.0"}]}'
        mock_urlopen.return_value.__enter__.return_value = mock_response
        self.assertEqual(update_flutter_source.get_latest_flutter_version(), "3.24.4")

    @patch('update_flutter_source.urllib.request.urlopen')
    def test_get_flutter_internal_version(self, mock_urlopen):
        mock_response = MagicMock()
        mock_response.read.return_value = b'abcdef123456\n'
        mock_urlopen.return_value.__enter__.return_value = mock_response
        self.assertEqual(update_flutter_source.get_flutter_internal_version("3.24.4", "engine.version"), "abcdef123456")

    def test_extract_hash_from_url_like(self):
        url = "flutter_infra_release/flutter/fonts/3012db47f3130e62f7cc0beabff968a33cbec8d8/fonts.zip"
        self.assertEqual(update_flutter_source.extract_hash_from_url_like(url), "3012db47f3130e62f7cc0beabff968a33cbec8d8")

        hash_only = "abcdef1234567890abcdef1234567890abcdef12"
        self.assertEqual(update_flutter_source.extract_hash_from_url_like(hash_only), hash_only)

    @patch('update_flutter_source.run_cmd')
    def test_check_branch_exists(self, mock_run_cmd):
        mock_run_cmd.return_value.returncode = 0
        self.assertTrue(update_flutter_source.check_branch_exists("my-branch"))

        mock_run_cmd.return_value.returncode = 2
        self.assertFalse(update_flutter_source.check_branch_exists("my-branch"))

        mock_run_cmd.return_value.returncode = 128
        with self.assertRaises(SystemExit):
            update_flutter_source.check_branch_exists("my-branch")

    @patch('update_flutter_source.run_cmd')
    def test_check_pr_exists(self, mock_run_cmd):
        mock_run_cmd.return_value.stdout = '[{"url": "http://pr"}]'
        self.assertTrue(update_flutter_source.check_pr_exists("my-branch"))

        mock_run_cmd.return_value.stdout = '[]'
        self.assertFalse(update_flutter_source.check_pr_exists("my-branch"))

        mock_run_cmd.side_effect = subprocess.CalledProcessError(1, 'gh')
        with self.assertRaises(subprocess.CalledProcessError):
            update_flutter_source.check_pr_exists("my-branch")

        mock_run_cmd.side_effect = FileNotFoundError()
        with self.assertRaises(SystemExit):
            update_flutter_source.check_pr_exists("my-branch")

    @patch('update_flutter_source.REPO_ROOT', Path("/fake/root"))
    @patch('pathlib.Path.exists', return_value=True)
    @patch('pathlib.Path.glob', return_value=[Path("/fake/root/dev-lang/flutter/flutter-3.24.4.ebuild")])
    def test_ebuild_exists(self, mock_glob, mock_exists):
        self.assertTrue(update_flutter_source.ebuild_exists("dev-lang/flutter", "3.24.4"))

if __name__ == '__main__':
    unittest.main()
