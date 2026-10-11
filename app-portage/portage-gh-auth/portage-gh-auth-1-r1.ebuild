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
	# The admin opts packages in with package.env; never modify that file.
	insinto /etc/portage/env
	newins "${FILESDIR}/github-auth.env" github-auth
}

pkg_postinst() {
	einfo "Installed reusable /etc/portage/env/github-auth for HTTPS GitHub fetches."
	einfo "Opt in individual packages in /etc/portage/package.env, e.g.:"
	einfo "    app-shells/a4sh github-auth"
	einfo "The package.env path can be a file or a directory; no edits were made."
	einfo "Verify that the portage user has authenticated GitHub CLI over HTTPS:"
	einfo "    sudo -u portage -H gh auth login --hostname github.com --git-protocol https"
	elog "Use read-only, repository-scoped credentials wherever possible."
	elog "gh may store credentials as plaintext if no credential store is available."
	elog "Credentials are not installed, copied, changed or revoked by this package."
	elog "For a different portage home, update GH_CONFIG_DIR in github-auth."
}
