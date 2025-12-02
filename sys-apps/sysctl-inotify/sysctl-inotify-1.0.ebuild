# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Ensure fs.inotify.max_user_instances is set at boot"
HOMEPAGE="https://example.invalid"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

# No sources, we just install configuration files
S="${WORKDIR}"

src_install() {
    insinto /etc/sysctl.d
    doins "${FILESDIR}"/99-inotify.conf
}

pkg_postinst() {
    elog "Installed /etc/sysctl.d/99-inotify.conf to set fs.inotify.max_user_instances to 1024."
    elog "Reload sysctl configuration with:"
    elog "    sysctl --system"
}
