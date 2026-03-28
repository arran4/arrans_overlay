EAPI=8

inherit autotools udev

DESCRIPTION="Library and utility to talk to iBoot/iBSS via USB"
HOMEPAGE="https://libimobiledevice.org https://github.com/libimobiledevice/libirecovery"
SRC_URI="https://github.com/libimobiledevice/${PN}/releases/download/${PV}/${P}.tar.bz2"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="
	>=app-pda/libimobiledevice-glue-1.2.0
	virtual/libusb:1
	sys-libs/readline:0=
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
	local myeconfargs=(
		--with-udev
		--with-udevrulesdir="$(get_udevdir)/rules.d"
		--disable-static
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
