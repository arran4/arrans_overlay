# Distributed under the terms of the GNU General Public License v2

import re

from sos.policies.distros import LinuxPolicy
from sos.policies.package_managers import PackageManager


class PortagePackageManager(PackageManager):
    """Use portage-utils to identify packages for generic sos plugins."""

    query_command = "qlist -ICv"

    def _parse_pkg_list(self, pkg_list):
        for line in pkg_list.splitlines():
            match = re.fullmatch(r"[^/]+/(.+?)-([0-9].*)", line.strip())
            if match:
                yield match.group(1), match.group(2), None


class GentooPolicy(LinuxPolicy):
    """Initial Gentoo Linux support for sos."""

    os_release_name = "Gentoo"
    os_release_id = "gentoo"
    os_release_file = "/etc/gentoo-release"
    vendor = "Gentoo"
    vendor_urls = [("Gentoo Linux", "https://www.gentoo.org/")]
    sos_pkg_name = "sos"

    def __init__(self, sysroot=None, init=None, probe_runtime=True,
                 remote_exec=None):
        super().__init__(sysroot=sysroot, init=init,
                         probe_runtime=probe_runtime, remote_exec=remote_exec)
        self.package_manager = PortagePackageManager(
            chroot=self.sysroot, remote_exec=remote_exec)
