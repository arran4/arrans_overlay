EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
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
	$(python_gen_cond_dep 'dev-python/setuptools[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/packaging[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/click[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/pyserial[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/cryptography[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/pyparsing[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/pyelftools[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/idf-component-manager[${PYTHON_USEDEP}]')
	dev-python/esp-coredump[${PYTHON_SINGLE_USEDEP}]
	dev-embedded/esptool[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep 'dev-python/esp-idf-kconfig[${PYTHON_USEDEP}]')
	dev-python/esp-idf-monitor[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep 'dev-python/esp-idf-nvs-partition-gen[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/esp-idf-size[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/esp-idf-diag[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/esp-idf-panic-decoder[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/esp-pylib[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/pyclang[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/construct[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/rich[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/psutil[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/tree-sitter[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/tree-sitter-c[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/freertos-gdb[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep '<dev-python/reedsolo-1.8[${PYTHON_USEDEP}]')
	dev-embedded/xtensa-esp-elf-bin
	dev-embedded/xtensa-esp-elf-gdb-bin
	dev-embedded/esp32ulp-elf-bin
	dev-embedded/openocd-esp32-bin
	dev-embedded/esp-rom-elfs
"
BDEPEND="app-arch/unzip"

S="${WORKDIR}/esp-idf-v${PV}"

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
	insinto /usr/share/esp-idf
	doins -r .

	fperms +x /usr/share/esp-idf/tools/idf.py

	# Generate the idf.py wrapper with the selected Python implementation
	cat > "${T}/idf.py" <<-EOF || die
	#!/bin/bash
	export IDF_PATH="/usr/share/esp-idf"
	export ESP_ROM_ELF_DIR="/usr/share/esp-rom-elfs"
	export OPENOCD_SCRIPTS="/opt/openocd-esp32/share/openocd/scripts"
	export PATH="/opt/openocd-esp32/bin:\$PATH"
	export IDF_PYTHON_ENV_PATH="/usr"
	export IDF_TOOLS_PATH="/usr/share/esp-idf"
	export IDF_PYTHON_CHECK_CONSTRAINTS="no"
	export ESP_IDF_VERSION="\${ESP_IDF_VERSION:-\$(cat /usr/share/esp-idf/version.txt 2>/dev/null || echo ${PV})}"
	export IDF_VERSION="\${IDF_VERSION:-\${ESP_IDF_VERSION}}"
	export PYTHON="\${PYTHON:-${PYTHON}}"
	exec "\${PYTHON}" "/usr/share/esp-idf/tools/idf.py" "\$@"
	EOF
	dobin "${T}/idf.py"

	# Provide a sourcable export.sh
	insinto /usr/share/esp-idf
	doins "${FILESDIR}/export.sh"
}

pkg_postinst() {
    elog "ESP-IDF openocd is available in PATH for esp-idf, or via /opt/openocd-esp32/bin/openocd."
    elog "To use ESP-IDF, source the environment script:"
    elog "  source /usr/share/esp-idf/export.sh"
}
