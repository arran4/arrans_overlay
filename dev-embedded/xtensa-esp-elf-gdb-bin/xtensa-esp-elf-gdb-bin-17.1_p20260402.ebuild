EAPI=8

DESCRIPTION="Espressif Xtensa GDB"
HOMEPAGE="https://github.com/espressif/binutils-gdb"
SRC_URI="https://github.com/espressif/binutils-gdb/releases/download/esp-gdb-v17.1_20260402/xtensa-esp-elf-gdb-17.1_20260402-x86_64-linux-gnu.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip binchecks"

QA_PREBUILT="opt/xtensa-esp-elf-gdb/*"

S="${WORKDIR}/xtensa-esp-elf-gdb"

src_install() {
	dodir /opt/xtensa-esp-elf-gdb
	cp -a . "${ED}/opt/xtensa-esp-elf-gdb/" || die

	# Remove gprof as it collides with xtensa-esp-elf-bin
	rm "${ED}/opt/xtensa-esp-elf-gdb/bin/xtensa-esp-elf-gprof" || die

	dodir /usr/bin
	for bin in "${ED}"/opt/xtensa-esp-elf-gdb/bin/*; do
		dosym "../../opt/xtensa-esp-elf-gdb/bin/${bin##*/}" "/usr/bin/${bin##*/}"
	done
}
