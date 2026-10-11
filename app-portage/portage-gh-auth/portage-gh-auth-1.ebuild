# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Use GitHub CLI credentials for private git-r3 fetches in Portage"
HOMEPAGE="https://github.com/arran4/arrans_overlay"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-util/github-cli"

S="${WORKDIR}"

src_install() {
	# Package-specific Portage environment files are loaded automatically.
	# Do not edit the administrator's package.env or credential store.
	insinto /etc/portage/env/app-shells
	newins "${FILESDIR}/a4sh.env" a4sh

	dodoc "${FILESDIR}/README.md"
}

pkg_postinst() {
	elog "Installed the Portage environment for app-shells/a4sh."
	elog "Authenticate the portage user separately using GitHub CLI over HTTPS:"
	elog "    sudo -u portage -H gh auth login --hostname github.com --git-protocol https"
	elog "Then test access with:"
	elog "    sudo -u portage -H git ls-remote https://github.com/arran4/shell.git HEAD"
	elog "See /usr/share/doc/${PF}/README.md* for security notes and other packages."
}
