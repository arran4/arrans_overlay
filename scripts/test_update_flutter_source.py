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


    @patch('tempfile.TemporaryDirectory')
    @patch('scripts.update_flutter_source.run_cmd')
    @patch('scripts.update_flutter_source.check_branch_exists')
    @patch('scripts.update_flutter_source.check_pr_exists')
    @patch('scripts.update_flutter_source.check_superseding_release')
    @patch('scripts.update_flutter_source.ebuild_exists')
    @patch('scripts.update_flutter_source.get_flutter_release')
    @patch('urllib.request.urlopen')
    def test_main_orchestration(self, mock_urlopen, mock_get_rel, mock_ebuild_exists, mock_super, mock_pr, mock_branch, mock_run_cmd, mock_tempdir):
        from scripts import update_flutter_source
        import sys

        # Test isolation
        import tempfile
        real_temp = tempfile.TemporaryDirectory()
        mock_tempdir.return_value.__enter__.return_value = real_temp.name

        mock_get_rel.return_value = {"version": "3.24.4", "hash": "abcdef", "channel": "stable"}
        mock_ebuild_exists.return_value = False
        mock_branch.return_value = False
        mock_pr.return_value = False
        mock_super.return_value = False

        from unittest.mock import MagicMock
        mock_response = MagicMock()
        def mock_read():
            return b"'dart_revision': 'abcdef123'"
        def mock_pubspec_read():
            return b"environment:\n  sdk: '^3.11.0-0'"

        mock_response.read.side_effect = lambda: mock_pubspec_read() if getattr(mock_urlopen, 'call_args') and mock_urlopen.call_args[0] and "pubspec.yaml" in mock_urlopen.call_args[0][0] else mock_read()
        mock_urlopen.return_value.__enter__.return_value = mock_response

        with patch('scripts.update_flutter_source.evaluate_dart_constraint', return_value=True):
            with patch('sys.argv', ['update_flutter_source.py', '--dry-run']):
                self.assertEqual(update_flutter_source.main(), 0)

            manifest_call_found = False
            for call in mock_run_cmd.call_args_list:
                if call and call[0] and 'verify_manifest.py' in str(call[0][0]):
                    manifest_call_found = True
                    break
            self.assertTrue(manifest_call_found, "verify_manifest.py must be called during dry run")

            push_call_found = False
            for call in mock_run_cmd.call_args_list:
                if call and call[0] and 'push' in call[0][0]:
                    push_call_found = True
                    break
            self.assertFalse(push_call_found, "push should not be called in dry run")

            mock_run_cmd.reset_mock()

            def mock_run_cmd_side_effect(cmd, **kwargs):
                if 'push' in cmd:
                    raise update_flutter_source.subprocess.CalledProcessError(1, cmd)
                if 'status' in cmd:
                    return update_flutter_source.subprocess.CompletedProcess(args=cmd, returncode=0, stdout='M some_file\n')
                return update_flutter_source.subprocess.CompletedProcess(args=cmd, returncode=0, stdout='')

            mock_run_cmd.side_effect = mock_run_cmd_side_effect

            with patch('scripts.update_flutter_source.REPO_ROOT', Path(real_temp.name)):
                with patch('sys.argv', ['update_flutter_source.py']):
                    self.assertEqual(update_flutter_source.main(), 1)

            push_call_found = False
            for call in mock_run_cmd.call_args_list:
                if call and call[0] and 'push' in call[0][0]:
                    push_call_found = True
                    break
            self.assertTrue(push_call_found, "push should be called")

            mock_run_cmd.reset_mock()
            # test branch recovery
            mock_branch.return_value = True
            mock_pr.return_value = False
            with patch('sys.argv', ['update_flutter_source.py']):
                with self.assertRaises(SystemExit):
                    update_flutter_source.main()


if __name__ == '__main__':
    unittest.main()
