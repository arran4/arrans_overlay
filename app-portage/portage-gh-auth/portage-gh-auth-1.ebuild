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

}

pkg_postinst() {
	einfo "Configured GitHub HTTPS credential helper for app-shells/a4sh."
	einfo "Authenticate the portage account (once) if not already logged in:"
	einfo "    sudo -u portage -H gh auth login --hostname github.com --git-protocol https"
	einfo "Verify private repository access:"
	einfo "    sudo -u portage -H git ls-remote https://github.com/arran4/shell.git HEAD"
	elog "Use a read-only, repository-scoped credential where possible."
	elog "gh may store authentication in plaintext if no secure credential store is available."
	elog "The package does not create, store, or revoke GitHub credentials."
	elog "For a nondefault portage home, adjust GH_CONFIG_DIR in the installed config."
}
