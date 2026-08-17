EAPI=8

MY_PV="${PV/_p/_}"

DESCRIPTION="Espressif Xtensa GCC Toolchain"
HOMEPAGE="https://github.com/espressif/crosstool-NG"
#SRC_URI="https://github.com/espressif/crosstool-NG/releases/download/esp-15.2.0_20251204/xtensa-esp-elf-15.2.0_20251204-x86_64-linux-gnu.tar.xz -> ${P}.tar.xz"

SRC_URI="
	amd64? ( https://github.com/espressif/crosstool-NG/releases/download/esp-${MY_PV}/xtensa-esp-elf-${MY_PV}-x86_64-linux-gnu.tar.xz )
	arm64? ( https://github.com/espressif/crosstool-NG/releases/download/esp-${MY_PV}/xtensa-esp-elf-${MY_PV}-aarch64-linux-gnu.tar.xz )
"

KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="|| ( amd64 arm64 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip binchecks"

QA_PREBUILT="opt/xtensa-esp-elf/*"

S="${WORKDIR}/xtensa-esp-elf"

pkg_pretend() {
	if [[ "${MY_ARCH}" == "unsupported" ]]; then
		eerror "The xtensa-esp-elf-bin toolchain does not support your system architecture."
		die "Unsupported architecture: ${ARCH}"
	fi
}

src_install() {
	dodir /opt/xtensa-esp-elf
	cp -a . "${ED}/opt/xtensa-esp-elf/" || die

	dodir /usr/bin
	for bin in "${ED}"/opt/xtensa-esp-elf/bin/*; do
		dosym "../../opt/xtensa-esp-elf/bin/${bin##*/}" "/usr/bin/${bin##*/}"
	done

	# gprof is provided by xtensa-esp-elf-gdb
	rm -f "${ED}/usr/bin/xtensa-esp-elf-gprof" || die
}
