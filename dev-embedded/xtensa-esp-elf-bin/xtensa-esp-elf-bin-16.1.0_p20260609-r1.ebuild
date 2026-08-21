# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV/_p/_}"

DESCRIPTION="Espressif Xtensa GCC Toolchain"
HOMEPAGE="https://github.com/espressif/crosstool-NG"
SRC_URI="
	amd64? ( https://github.com/espressif/crosstool-NG/releases/download/esp-${MY_PV}/xtensa-esp-elf-${MY_PV}-x86_64-linux-gnu.tar.xz )
	arm64? ( https://github.com/espressif/crosstool-NG/releases/download/esp-${MY_PV}/xtensa-esp-elf-${MY_PV}-aarch64-linux-gnu.tar.xz )
"
S="${WORKDIR}/xtensa-esp-elf"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip binchecks"

QA_PREBUILT="opt/xtensa-esp-elf/*"

src_install() {
	dodir /opt/xtensa-esp-elf
	cp -a . "${ED}/opt/xtensa-esp-elf/" || die

	# Remove gprof as it is provided by xtensa-esp-elf-gdb-bin
	rm -f "${ED}/opt/xtensa-esp-elf/bin/xtensa-esp-elf-gprof" || die

	dodir /usr/bin
	for bin in "${ED}"/opt/xtensa-esp-elf/bin/*; do
		dosym "../../opt/xtensa-esp-elf/bin/${bin##*/}" "/usr/bin/${bin##*/}"
	done
}
