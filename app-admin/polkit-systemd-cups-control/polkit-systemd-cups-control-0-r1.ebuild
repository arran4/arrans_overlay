# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Polkit rules for systemctl control of cups.service"
HOMEPAGE="https://github.com/arran4/arrans-overlay"
SRC_URI=""
S="${WORKDIR}"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	sys-auth/polkit
	acct-group/systemctl-operators
"

src_install() {
	insinto /etc/polkit-1/rules.d
	doins "${FILESDIR}/50-systemctl-cups.rules"
}

pkg_postinst() {
	elog "The Polkit policy for cups.service was installed."
	elog "To allow a user to use these delegated rules, add them to the systemctl-operators group:"
	elog "gpasswd -a <username> systemctl-operators"
	elog ""
	elog "Users must log out and log back in for group membership to apply."
}
