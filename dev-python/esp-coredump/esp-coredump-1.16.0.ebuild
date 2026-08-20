EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-coredump"
SRC_URI="https://files.pythonhosted.org/packages/d0/9c/17e2134e8573837af47631d4dd27ba3001aa557dfe63a890df4aa2dad006/esp_coredump-1.16.0.tar.gz"
HOMEPAGE="https://pypi.org/project/esp-coredump/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"


python_install() {
	distutils-r1_python_install
	rm -rv "${D}$(python_get_sitedir)/tests" || die
}

RDEPEND="
	$(python_gen_cond_dep 'dev-python/construct[${PYTHON_USEDEP}]')
	$(python_gen_cond_dep 'dev-python/pygdbmi[${PYTHON_USEDEP}]')
	dev-embedded/esptool[${PYTHON_SINGLE_USEDEP}]
"

