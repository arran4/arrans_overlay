#!/usr/bin/env python3
import json
import logging
import os
import subprocess
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

import update_which_browser

class TestUpdateWhichBrowser(unittest.TestCase):

    @patch("update_which_browser.run_cmd")
    def test_get_github_releases(self, mock_run_cmd):
        mock_res = MagicMock()
        mock_res.stdout = '[{"tag_name": "v0.2.22+162", "assets": [{"name": "which_browser-0.2.22+162-linux.deb"}]}]'
        mock_run_cmd.return_value = mock_res

        releases = update_which_browser.get_github_releases()
        self.assertEqual(len(releases), 1)
        self.assertEqual(releases[0]["tag_name"], "v0.2.22+162")

    @patch("urllib.request.urlopen")
    def test_validate_url_success(self, mock_urlopen):
        mock_response = MagicMock()
        mock_response.status = 200
        mock_response.__enter__.return_value = mock_response
        mock_urlopen.return_value = mock_response

        self.assertTrue(update_which_browser.validate_url("https://example.com/file.deb"))

    @patch("urllib.request.urlopen")
    def test_validate_url_failure(self, mock_urlopen):
        import urllib.error
        mock_urlopen.side_effect = urllib.error.HTTPError("url", 404, "Not Found", {}, None)

        self.assertFalse(update_which_browser.validate_url("https://example.com/file.deb"))

    @patch("update_which_browser.run_cmd")
    def test_check_pr_exists(self, mock_run_cmd):
        mock_res = MagicMock()
        mock_res.stdout = '[{"url": "https://github.com/..."}]'
        mock_run_cmd.return_value = mock_res

        self.assertTrue(update_which_browser.check_pr_exists("v0.2.22+162"))

    @patch("update_which_browser.validate_url")
    @patch("update_which_browser.check_pr_exists")
    @patch("update_which_browser.check_ebuild_exists")
    @patch("update_which_browser.get_github_releases")
    @patch("update_which_browser.generate_ebuild")
    def test_main_success_validation(self, mock_generate, mock_get_releases, mock_check_ebuild, mock_check_pr, mock_validate):
        import os
        os.environ.pop("GITHUB_OUTPUT", None)
        mock_get_releases.return_value = [
            {"tag_name": "v0.2.22+162", "assets": [{"name": "which_browser-0.2.22+162-linux.deb"}]}
        ]
        mock_check_ebuild.return_value = False
        mock_check_pr.return_value = False
        mock_validate.return_value = True

        import io
        from contextlib import redirect_stdout
        f = io.StringIO()
        with redirect_stdout(f):
            update_which_browser.main()

        output = f.getvalue()
        self.assertIn("generated_version=0.2.22.162", output)
        mock_generate.assert_called_once()

    @patch("update_which_browser.validate_url")
    @patch("update_which_browser.check_pr_exists")
    @patch("update_which_browser.check_ebuild_exists")
    @patch("update_which_browser.get_github_releases")
    @patch("update_which_browser.generate_ebuild")
    def test_main_failed_validation(self, mock_generate, mock_get_releases, mock_check_ebuild, mock_check_pr, mock_validate):
        import os
        os.environ.pop("GITHUB_OUTPUT", None)
        mock_get_releases.return_value = [
            {"tag_name": "v0.2.22+162", "assets": [{"name": "which_browser-0.2.22+162-linux.deb"}]}
        ]
        mock_check_ebuild.return_value = False
        mock_check_pr.return_value = False
        mock_validate.return_value = False

        import io
        from contextlib import redirect_stdout
        f = io.StringIO()
        with redirect_stdout(f):
            update_which_browser.main()

        output = f.getvalue()
        self.assertNotIn("generated_version", output)
        mock_generate.assert_not_called()

    @patch("update_which_browser.get_github_releases")
    @patch("update_which_browser.generate_ebuild")
    def test_missing_assets(self, mock_generate, mock_get_releases):
        # Empty assets list
        mock_get_releases.return_value = [
            {"tag_name": "v0.2.22+162", "assets": []}
        ]

        import io
        from contextlib import redirect_stdout
        f = io.StringIO()
        with redirect_stdout(f):
            update_which_browser.main()

        output = f.getvalue()
        self.assertNotIn("generated_version", output)
        mock_generate.assert_not_called()

    @patch("update_which_browser.validate_url")
    @patch("update_which_browser.check_pr_exists")
    @patch("update_which_browser.check_ebuild_exists")
    @patch("update_which_browser.get_github_releases")
    @patch("update_which_browser.generate_ebuild")
    def test_incorrect_checksum_manifest_failure(self, mock_generate, mock_get_releases, mock_check_ebuild, mock_check_pr, mock_validate):
        # Test that if manifest generation fails (e.g. incorrect checksum inside g2), it handles it
        mock_get_releases.return_value = [
            {"tag_name": "v0.2.22+162", "assets": [{"name": "which_browser-0.2.22+162-linux.deb"}]}
        ]
        mock_check_ebuild.return_value = False
        mock_check_pr.return_value = False
        mock_validate.return_value = True

        # Make generate_ebuild raise an exception
        mock_generate.side_effect = Exception("Manifest generation failed")

        import io
        from contextlib import redirect_stdout
        f = io.StringIO()
        with redirect_stdout(f):
            update_which_browser.main()

        output = f.getvalue()
        self.assertNotIn("generated_version", output)

if __name__ == "__main__":
    unittest.main()
