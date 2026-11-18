# Distributed under the terms of the GNU General Public License v2

from sos.policies.distros import LinuxPolicy
from sos.policies.package_managers import PackageManager


class PortagePackageManager(PackageManager):
    """Use portage-utils to identify packages for generic sos plugins."""

    query_command = "qlist -IC -F '%{CATEGORY}/%{PN} %{PVR}'"

    def _parse_pkg_list(self, pkg_list):
        # Explicit qlist format provides category/package and version.
        # Preserve the unqualified package names used by independent plugins.
        for line in pkg_list.splitlines():
            fields = line.split()
            if len(fields) != 2 or fields[0].count("/") != 1:
                continue
            category, name = fields[0].split("/")
            version = fields[1]
            if category and name and version[0].isdigit():
                yield name, version, None


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
