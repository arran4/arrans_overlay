# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="Restore/upgrade firmware of iOS devices"
HOMEPAGE="https://libimobiledevice.org/"
EGIT_REPO_URI="https://github.com/libimobiledevice/idevicerestore.git"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS=""

DEPEND="
	>=app-pda/libimobiledevice-1.4.0:=
	>=app-pda/libirecovery-1.3.0:=
	>=app-pda/libtatsu-1.0.4:=
	>=app-pda/libusbmuxd-2.0.2:=
	>=dev-libs/libimobiledevice-glue-1.3.0:=
	>=dev-libs/libplist-2.6.0:=
	>=dev-libs/libzip-1.0:=
	net-misc/curl
	sys-libs/zlib
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
