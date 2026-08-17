EAPI=8

DESCRIPTION="Espressif ROM ELF files"
HOMEPAGE="https://github.com/espressif/esp-rom-elfs"
SRC_URI="https://github.com/espressif/esp-rom-elfs/releases/download/${PV}/esp-rom-elfs-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"
QA_PREBUILT="usr/share/esp-rom-elfs/*"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	unpack ${A}
}

src_install() {
	dodir /usr/share/esp-rom-elfs
	cp -a . "${ED}/usr/share/esp-rom-elfs/" || die
}
