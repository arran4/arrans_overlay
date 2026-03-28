# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="Library and utility to talk to iBoot/iBSS via USB"
HOMEPAGE="https://libimobiledevice.org/"
EGIT_REPO_URI="https://github.com/libimobiledevice/libirecovery.git"

LICENSE="LGPL-2.1"
SLOT="0/3"
KEYWORDS=""
IUSE="static-libs"

DEPEND="
	>=dev-libs/libimobiledevice-glue-1.3.0:=
	virtual/libusb:1
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
