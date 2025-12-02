# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Sets custom systemd NOFILE limits"
HOMEPAGE="https://example.invalid"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

# No sources, just install files
S="${WORKDIR}"

src_install() {
    # Install the systemd override directory
    insinto /etc/systemd/system.conf.d

    # Install the config file
    newins "${FILESDIR}/limits.conf" limits.conf
}

pkg_postinst() {
    elog "Installed /etc/systemd/system.conf.d/limits.conf"
    elog "To apply new NOFILE limits, run:"
    elog "    sudo systemctl daemon-reexec"
    elog "or reboot."
}
