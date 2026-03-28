# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Restore/upgrade firmware of iOS devices"
HOMEPAGE="https://libimobiledevice.org/"
SRC_URI="https://github.com/libimobiledevice/${PN}/releases/download/${PV}/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=app-pda/libimobiledevice-1.3.0:=
	>=app-pda/libirecovery-1.0.0:=
	>=app-pda/libplist-2.2.0:=
	>=dev-libs/libzip-0.8:=
	dev-libs/openssl:0=
	net-misc/curl
	sys-libs/zlib
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-remove-irecv-init.patch"
	"${FILESDIR}/${P}-libzip-openssl3.patch"
)

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
