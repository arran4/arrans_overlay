EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-idf-panic-decoder"
SRC_URI="https://files.pythonhosted.org/packages/da/f1/e4d6170a51e15afd27660992fbd2a4728cf401750ebb388b1ce035d95025/esp_idf_panic_decoder-1.5.0.tar.gz"
HOMEPAGE="https://pypi.org/project/esp-idf-panic-decoder/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/esp-coredump[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep 'dev-python/esp-pylib[${PYTHON_USEDEP}]')
"
DEPEND="${RDEPEND}"
