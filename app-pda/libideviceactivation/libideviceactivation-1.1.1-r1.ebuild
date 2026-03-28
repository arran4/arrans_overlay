EAPI=8

DESCRIPTION="A library to manage the activation process of Apple iOS devices"
HOMEPAGE="https://www.libimobiledevice.org/ https://github.com/libimobiledevice/libideviceactivation"
SRC_URI="https://github.com/libimobiledevice/${PN}/releases/download/${PV}/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=app-pda/libimobiledevice-1.3.0:=
	>=dev-libs/libplist-2.2.0:=
	>=net-misc/curl-7.20:=
	>=dev-libs/libxml2-2.9:=
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
