EAPI=8

inherit autotools git-r3

DESCRIPTION="A library to manage the activation process of Apple iOS devices"
HOMEPAGE="https://www.libimobiledevice.org/ https://github.com/libimobiledevice/libideviceactivation"
EGIT_REPO_URI="https://github.com/libimobiledevice/${PN}.git"

LICENSE="LGPL-3"
SLOT="0"

DEPEND="
	>=app-pda/libimobiledevice-1.3.0:=
	>=app-pda/libplist-2.2.0:=
	>=net-misc/curl-7.20:=
	>=dev-libs/libxml2-2.9:=
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
