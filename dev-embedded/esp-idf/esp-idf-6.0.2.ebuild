EAPI=8

PYTHON_COMPAT=( python3_{10..15} )
inherit python-single-r1

DESCRIPTION="Espressif IoT Development Framework"
HOMEPAGE="https://github.com/espressif/esp-idf"
SRC_URI="https://dl.espressif.com/github_assets/espressif/esp-idf/releases/download/v6.0.2/esp-idf-v6.0.2.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# We depend on python, git, cmake, ninja, ccache, flex, bison, gperf, libusb
DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}
	dev-vcs/git
	dev-build/cmake
	dev-build/ninja
	sys-devel/flex
	sys-devel/bison
	dev-util/gperf
	dev-util/ccache
	virtual/libusb:1
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/pyserial[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/pyparsing[${PYTHON_USEDEP}]
	dev-python/pyelftools[${PYTHON_USEDEP}]
	dev-python/idf-component-manager[${PYTHON_USEDEP}]
	dev-python/esp-coredump[${PYTHON_USEDEP}]
	dev-embedded/esptool[${PYTHON_USEDEP}]
	dev-python/esp-idf-kconfig[${PYTHON_USEDEP}]
	dev-python/esp-idf-monitor[${PYTHON_USEDEP}]
	dev-python/esp-idf-nvs-partition-gen[${PYTHON_USEDEP}]
	dev-python/esp-idf-size[${PYTHON_USEDEP}]
	dev-python/esp-idf-diag[${PYTHON_USEDEP}]
	dev-python/esp-idf-panic-decoder[${PYTHON_USEDEP}]
	dev-python/pyclang[${PYTHON_USEDEP}]
	dev-python/construct[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/tree-sitter[${PYTHON_USEDEP}]
	dev-python/tree-sitter-c[${PYTHON_USEDEP}]
	dev-python/freertos-gdb[${PYTHON_USEDEP}]
	dev-embedded/xtensa-esp-elf-bin
	dev-embedded/xtensa-esp-elf-gdb-bin
	dev-embedded/esp32ulp-elf-bin
	dev-embedded/openocd-esp32-bin
	dev-embedded/esp-rom-elfs
"
BDEPEND="app-arch/unzip"

S="${WORKDIR}/${P}"

src_prepare() {
	default
	# Use standard version.txt
	echo "${PV}" > version.txt
	# Remove git directories
	find . -type d -name ".git" -exec rm -rf {} + || die
}

src_compile() {
	# No compile phase for esp-idf itself, it's a framework we copy
	:
}

src_install() {
	dodir /usr/share/esp-idf
	cp -a . "${ED}/usr/share/esp-idf/" || die

	# Provide an idf.py wrapper
	newbin "${FILESDIR}/idf.py" idf.py

	# Provide env.d file
	cat > "${T}/99esp-idf" <<-EOENV
		IDF_PATH="/usr/share/esp-idf"
		ESP_ROM_ELF_DIR="/usr/share/esp-rom-elfs"
		OPENOCD_SCRIPTS="/opt/openocd-esp32/share/openocd/scripts"
		IDF_PYTHON_ENV_PATH="/usr"
		IDF_TOOLS_PATH="/usr/share/esp-idf"
	EOENV
	doenvd "${T}/99esp-idf"
}

pkg_postinst() {
    elog "ESP-IDF openocd is available in PATH for esp-idf, or via /opt/openocd-esp32/bin/openocd."
}
