# Distributed under the terms of the GNU General Public License v2
import unittest
from unittest.mock import Mock, call, patch

from sos.policies.distros.gentoo import GentooPolicy, PortagePackageManager
from sos.report.plugins.portage import Portage


class GentooPolicyTests(unittest.TestCase):
    def test_remote_distribution_detection(self):
        for release in ('ID=gentoo\n', 'NAME="Gentoo"\nID=gentoo\n'):
            with self.subTest(release=release):
                self.assertTrue(GentooPolicy.check(remote=release))
        for release in ('ID=debian\n', 'ID=other\n', 'ID=gentooish\n'):
            with self.subTest(release=release):
                self.assertFalse(GentooPolicy.check(remote=release))
        derivative = 'ID=other\nID_LIKE=gentoo\n'
        self.assertTrue(GentooPolicy.check(remote=derivative))
        self.assertFalse(GentooPolicy.check_primary(remote=derivative))
        self.assertTrue(GentooPolicy.check_primary(remote='ID=gentoo\n'))

    def test_package_columns(self):
        fixture = (
            'sys-apps/portage 3.0.70-r1\n'
            'media-video/pipewire 1.4.0\n'
            'app-example/foo-2-tools 1.0_rc2\n'
            '\ninvalid\nno-category 1.0\ncat/ nonversion\n'
        )
        pm = PortagePackageManager()
        self.assertEqual(list(pm._parse_pkg_list(fixture)), [
            ('portage', '3.0.70-r1', None),
            ('pipewire', '1.4.0', None),
            ('foo-2-tools', '1.0_rc2', None),
        ])
        self.assertEqual(list(pm._parse_pkg_list('')), [])

    def test_package_queries_and_cache(self):
        pm = PortagePackageManager()
        with patch.object(pm, 'exec_cmd', return_value='sys-apps/portage 3.0.70-r1\n') as run:
            self.assertEqual(pm.pkg_by_name('portage')['version'], ['3', '0', '70-r1'])
            self.assertIsNone(pm.pkg_by_name('not-installed'))
            self.assertEqual(pm.all_pkgs_by_name('port*'), ['portage'])
            run.assert_called_once_with(
                "qlist -IC -F '%{CATEGORY}/%{PN} %{PVR}'",
                timeout=30, chroot=None)

    def test_plugin_requests_read_only_data(self):
        plugin = Mock()
        Portage.setup(plugin)
        self.assertEqual(plugin.add_cmd_output.call_args_list, [
            call('emerge --info', suggest_filename='emerge-info'),
            call('qlist -ICv', suggest_filename='installed-packages'),
            call('qlist -ICvU', suggest_filename='installed-use-flags'),
            call('eselect profile show', suggest_filename='profile'),
        ])
        plugin.add_copy_spec.assert_called_once_with([
            '/var/lib/portage/world', '/var/lib/portage/world_sets',
        ])


if __name__ == '__main__':
    unittest.main()
