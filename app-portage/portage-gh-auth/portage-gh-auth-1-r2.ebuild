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
	einfo "Installed /etc/portage/env/github-auth for GitHub HTTPS fetches."
	einfo "Opt in via /etc/portage/package.env (file or directory):"
	einfo "    app-shells/a4sh github-auth"
	einfo "No package.env entries were changed."
	einfo "Authenticate GitHub CLI as the portage user:"
	einfo "    sudo -u portage -H gh auth login -h github.com -p https"
	elog "Prefer read-only, repository-scoped credentials."
	elog "gh may store credentials as plaintext without a secure store."
	elog "This package never installs, changes, or revokes credentials."
	elog "For another portage home, adjust GH_CONFIG_DIR in github-auth."
}
