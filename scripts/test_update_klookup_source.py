import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import MagicMock, patch

import update_klookup_source as updater

LIVE_FIXTURE = '''EAPI=8
inherit cmake git-r3
DESCRIPTION="KDE Plasma 6 lookup tool with search providers"
HOMEPAGE="https://github.com/arran4/klookup"
EGIT_REPO_URI="https://github.com/arran4/klookup.git"
KEYWORDS=""
DEPEND="dev-qt/qtbase:6[dbus,gui,network,widgets]"
'''


class TestUpdater(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.original_cwd = os.getcwd()
        os.chdir(self.tempdir.name)
        updater.PACKAGE_DIR.mkdir(parents=True)
        updater.LIVE_EBUILD.write_text(LIVE_FIXTURE)

    def tearDown(self):
        os.chdir(self.original_cwd)
        self.tempdir.cleanup()

    @patch('update_klookup_source.urllib.request.urlopen')
    def test_no_releases(self, urlopen):
        response = MagicMock()
        response.read.return_value = b'[]'
        urlopen.return_value.__enter__.return_value = response
        self.assertEqual(updater.get_releases(), [])
        with patch.object(updater, 'get_releases', return_value=[]), \
             patch('update_klookup_source.subprocess.run') as run:
            updater.main()
        run.assert_not_called()

    def test_filters_drafts_prereleases_bad_tags_and_duplicates(self):
        releases = [
            {'tag_name': 'v1.0.0', 'draft': True},
            {'tag_name': 'v2.0.0', 'prerelease': True},
            {'tag_name': '../escape'},
            {'tag_name': 'v1.0.0'},
            {'tag_name': '1.0.0'},
            {'tag_name': 'v1.0.0-rc1'},
            {'tag_name': 'v1.2.0'},
        ]
        self.assertEqual(list(updater.eligible_releases(releases)),
                         [('v1.0.0', '1.0.0'), ('v1.2.0', '1.2.0')])

    @patch('update_klookup_source.subprocess.run')
    @patch.object(updater, 'get_releases', return_value=[{'tag_name': 'v1.0.0'}])
    def test_generates_source_ebuild_manifest_and_cache(self, get_releases, run):
        updater.main()
        generated = (updater.PACKAGE_DIR / 'klookup-1.0.0.ebuild').read_text()
        self.assertIn('inherit cmake\n', generated)
        self.assertNotIn('git-r3', generated)
        self.assertIn('SRC_URI="https://github.com/arran4/klookup/archive/refs/tags/v1.0.0.tar.gz -> ${P}.tar.gz"', generated)
        self.assertIn('S="${WORKDIR}/klookup-${PV}"', generated)
        self.assertIn('KEYWORDS="~amd64"', generated)
        self.assertIn('dev-qt/qtbase:6[dbus,gui,network,widgets]', generated)
        self.assertEqual(run.call_count, 2)
        self.assertEqual(run.call_args_list[0].args[0],
                         ['g2', 'manifest', 'upsert-from-url',
                          'https://github.com/arran4/klookup/archive/refs/tags/v1.0.0.tar.gz',
                          'klookup-1.0.0.tar.gz', 'app-misc/klookup/Manifest'])
        self.assertEqual(run.call_args_list[1].args[0],
                         ['g2', 'cache', 'generate', 'app-misc/klookup'])
        self.assertTrue(all(call.kwargs['check'] for call in run.call_args_list))
        run.reset_mock()
        updater.main()
        run.assert_not_called()

    @patch('update_klookup_source.subprocess.run')
    @patch.object(updater, 'get_releases', return_value=[{'tag_name': '1.0.0'}, {'tag_name': 'v1.1.0'}])
    def test_existing_does_not_hide_newer_and_unprefixed_tags(self, get_releases, run):
        (updater.PACKAGE_DIR / 'klookup-1.0.0.ebuild').write_text('existing')
        updater.main()
        self.assertEqual((updater.PACKAGE_DIR / 'klookup-1.0.0.ebuild').read_text(), 'existing')
        self.assertTrue((updater.PACKAGE_DIR / 'klookup-1.1.0.ebuild').is_file())
        self.assertIn('refs/tags/v1.1.0.tar.gz', (updater.PACKAGE_DIR / 'klookup-1.1.0.ebuild').read_text())
        self.assertEqual(run.call_count, 2)

    @patch('update_klookup_source.subprocess.run', side_effect=subprocess.CalledProcessError(1, 'g2'))
    @patch.object(updater, 'get_releases', return_value=[{'tag_name': 'v1.0.0'}])
    def test_manifest_failure_prevents_pr(self, get_releases, run):
        with self.assertRaises(subprocess.CalledProcessError):
            updater.main()
        self.assertEqual(run.call_count, 1)

    @patch('update_klookup_source.urllib.request.urlopen', side_effect=OSError('offline'))
    def test_api_failure_is_not_silent(self, urlopen):
        with self.assertRaises(OSError):
            updater.get_releases()


if __name__ == '__main__':
    unittest.main()
