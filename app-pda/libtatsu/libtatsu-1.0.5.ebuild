# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Library to handle Apple's TSS protocol"
HOMEPAGE="https://libimobiledevice.org/"
SRC_URI="https://github.com/libimobiledevice/${PN}/releases/download/${PV}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0/0"
KEYWORDS="~amd64"
IUSE="static-libs"

DEPEND="
	>=app-pda/libplist-2.3.0:=
	net-misc/curl
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
