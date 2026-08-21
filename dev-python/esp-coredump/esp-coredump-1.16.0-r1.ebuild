EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-coredump"
PYPI_PN="esp_coredump"
HOMEPAGE="https://pypi.org/project/esp-coredump/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

python_install() {
	distutils-r1_python_install

	# Should not install tests
	rm -rf "${D}$(python_get_sitedir)/tests" || die
}
