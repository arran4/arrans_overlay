EAPI=8

DESCRIPTION="Espressif Xtensa GCC Toolchain"
HOMEPAGE="https://github.com/espressif/crosstool-NG"
SRC_URI="https://github.com/espressif/crosstool-NG/releases/download/esp-15.2.0_20251204/xtensa-esp-elf-15.2.0_20251204-x86_64-linux-gnu.tar.xz -> ${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip binchecks"

QA_PREBUILT="opt/xtensa-esp-elf/*"

S="${WORKDIR}/xtensa-esp-elf"

src_install() {
	dodir /opt/xtensa-esp-elf
	cp -a . "${ED}/opt/xtensa-esp-elf/" || die

	dodir /usr/bin
	for bin in "${ED}"/opt/xtensa-esp-elf/bin/*; do
		dosym "../../opt/xtensa-esp-elf/bin/${bin##*/}" "/usr/bin/${bin##*/}"
	done
}
