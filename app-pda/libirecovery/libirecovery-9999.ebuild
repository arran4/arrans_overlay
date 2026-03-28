EAPI=8

inherit autotools git-r3 udev

DESCRIPTION="Library and utility to talk to iBoot/iBSS via USB"
HOMEPAGE="https://libimobiledevice.org https://github.com/libimobiledevice/libirecovery"
EGIT_REPO_URI="https://github.com/libimobiledevice/libirecovery.git"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS=""

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
