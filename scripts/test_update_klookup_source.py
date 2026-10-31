import unittest
from unittest.mock import patch, Mock
import json
import urllib.error
import os

# Import the module to be tested
import update_klookup_source

class TestUpdateKlookupSource(unittest.TestCase):

    @patch('update_klookup_source.urllib.request.urlopen')
    def test_get_latest_release_no_releases(self, mock_urlopen):
        # Mock an empty list response (no releases)
        mock_response = Mock()
        mock_response.status = 200
        mock_response.read.return_value = json.dumps([]).encode('utf-8')
        mock_response.__enter__ = Mock(return_value=mock_response)
        mock_response.__exit__ = Mock(return_value=None)
        mock_urlopen.return_value = mock_response

        release = update_klookup_source.get_latest_release()
        self.assertIsNone(release)

    @patch('update_klookup_source.urllib.request.urlopen')
    def test_get_latest_release_valid_release(self, mock_urlopen):
        # Mock a valid release response
        mock_response = Mock()
        mock_response.status = 200
        mock_response.read.return_value = json.dumps([{"tag_name": "v1.0.0"}]).encode('utf-8')
        mock_response.__enter__ = Mock(return_value=mock_response)
        mock_response.__exit__ = Mock(return_value=None)
        mock_urlopen.return_value = mock_response

        release = update_klookup_source.get_latest_release()
        self.assertEqual(release, "1.0.0")

    @patch('update_klookup_source.urllib.request.urlopen')
    def test_get_latest_release_http_error(self, mock_urlopen):
        # Mock an HTTP error
        mock_urlopen.side_effect = urllib.error.HTTPError(
            "url", 404, "Not Found", {}, None
        )

        release = update_klookup_source.get_latest_release()
        self.assertIsNone(release)

    @patch('update_klookup_source.urllib.request.urlopen')
    def test_get_latest_release_invalid_json(self, mock_urlopen):
        # Mock an invalid JSON response
        mock_response = Mock()
        mock_response.status = 200
        mock_response.read.return_value = b"invalid json"
        mock_response.__enter__ = Mock(return_value=mock_response)
        mock_response.__exit__ = Mock(return_value=None)
        mock_urlopen.return_value = mock_response

        release = update_klookup_source.get_latest_release()
        self.assertIsNone(release)

    @patch('update_klookup_source.os.makedirs')
    def test_generate_ebuild(self, mock_makedirs):
        version = "1.0.0"
        ebuild_path = f"app-misc/klookup/klookup-{version}.ebuild"

        # Test creation of ebuild
        with patch("builtins.open", unittest.mock.mock_open()) as mock_file:
            generated_path = update_klookup_source.generate_ebuild(version)
            self.assertEqual(generated_path, ebuild_path)
            mock_file.assert_called_with(ebuild_path, "w")
            handle = mock_file()
            # Assert some expected content is written
            written_data = "".join(call.args[0] for call in handle.write.call_args_list)
            self.assertIn('DESCRIPTION="KDE Plasma 6 lookup tool with search providers"', written_data)
            self.assertIn('SRC_URI="https://github.com/arran4/klookup/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"', written_data)
            self.assertNotIn('git-r3', written_data)

    @patch('update_klookup_source.os.path.exists')
    def test_version_exists(self, mock_exists):
        mock_exists.return_value = True
        self.assertTrue(update_klookup_source.version_exists("1.0.0"))
        mock_exists.assert_called_with("app-misc/klookup/klookup-1.0.0.ebuild")

    @patch('update_klookup_source.subprocess.run')
    def test_update_manifest_and_cache(self, mock_run):
        update_klookup_source.update_manifest_and_cache("1.0.0")
        self.assertEqual(mock_run.call_count, 2)

if __name__ == '__main__':
    unittest.main()

    @patch('update_klookup_source.os.makedirs')
    def test_generate_ebuild(self, mock_makedirs):
        version = "1.0.0"
        ebuild_path = f"app-misc/klookup/klookup-{version}.ebuild"

        # Test creation of ebuild
        with patch("builtins.open", unittest.mock.mock_open()) as mock_file:
            generated_path = update_klookup_source.generate_ebuild(version)
            self.assertEqual(generated_path, ebuild_path)
            mock_file.assert_called_with(ebuild_path, "w")
            handle = mock_file()
            # Assert some expected content is written
            written_data = "".join(call.args[0] for call in handle.write.call_args_list)
            self.assertIn('DESCRIPTION="KDE Plasma 6 lookup tool with search providers"', written_data)
            self.assertIn('SRC_URI="https://github.com/arran4/klookup/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"', written_data)
            self.assertNotIn('git-r3', written_data)

    @patch('update_klookup_source.os.path.exists')
    def test_version_exists(self, mock_exists):
        mock_exists.return_value = True
        self.assertTrue(update_klookup_source.version_exists("1.0.0"))
        mock_exists.assert_called_with("app-misc/klookup/klookup-1.0.0.ebuild")

    @patch('update_klookup_source.subprocess.run')
    def test_update_manifest_and_cache(self, mock_run):
        update_klookup_source.update_manifest_and_cache("1.0.0")
        self.assertEqual(mock_run.call_count, 2)
