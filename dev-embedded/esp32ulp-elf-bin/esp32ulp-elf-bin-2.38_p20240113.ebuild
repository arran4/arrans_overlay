EAPI=8

DESCRIPTION="Espressif ULP GCC Toolchain"
HOMEPAGE="https://github.com/espressif/binutils-gdb"
SRC_URI="https://github.com/espressif/binutils-gdb/releases/download/esp32ulp-elf-2.38_20240113/esp32ulp-elf-2.38_20240113-linux-amd64.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip binchecks"

QA_PREBUILT="opt/esp32ulp-elf/*"

S="${WORKDIR}/esp32ulp-elf"

src_install() {
	dodir /opt/esp32ulp-elf
	cp -a . "${ED}/opt/esp32ulp-elf/" || die

	dodir /usr/bin
	for bin in "${ED}"/opt/esp32ulp-elf/bin/*; do
		dosym "../../opt/esp32ulp-elf/bin/${bin##*/}" "/usr/bin/${bin##*/}"
	done
}
