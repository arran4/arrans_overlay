# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs systemd

DESCRIPTION="Lightweight Identity Manager"
HOMEPAGE="https://github.com/javalsai/lidm"
SRC_URI="https://github.com/javalsai/lidm/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="sys-libs/pam"
RDEPEND="${DEPEND}"
BDEPEND=""

src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" INFO_GIT_REV="${PV}"
}

src_install() {
	emake install PREFIX=/usr DESTDIR="${D}"

	# OpenRC service
	# Fix path to lidm binary, ensuring we don't break it if it's already /usr/bin/lidm
	sed -i "s| -nl /bin/lidm| -nl ${EPREFIX}/usr/bin/lidm|" assets/services/openrc || die
	newinitd assets/services/openrc lidm

	# Systemd unit
	sed -e "s|ExecStart=/usr/bin/lidm|ExecStart=${EPREFIX}/usr/bin/lidm|" \
		assets/services/systemd.service > lidm.service || die
	systemd_dounit lidm.service
}

pkg_postinst() {
	elog "For YubiKey support, please refer to:"
	elog "https://github.com/javalsai/lidm/blob/master/docs/yubikey.md"
}
