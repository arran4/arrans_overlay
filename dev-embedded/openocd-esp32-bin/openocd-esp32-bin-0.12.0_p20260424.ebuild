EAPI=8

DESCRIPTION="Espressif OpenOCD"
HOMEPAGE="https://github.com/espressif/openocd-esp32"
SRC_URI="https://github.com/espressif/openocd-esp32/releases/download/v0.12.0-esp32-20260424/openocd-esp32-linux-amd64-0.12.0-esp32-20260424.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip binchecks"

QA_PREBUILT="opt/openocd-esp32/bin/*"

S="${WORKDIR}/openocd-esp32"

src_install() {
	dodir /opt/openocd-esp32
	cp -a . "${ED}/opt/openocd-esp32/" || die

	dodir /usr/bin
	dosym ../../opt/openocd-esp32/bin/openocd /usr/bin/openocd-esp32
}
