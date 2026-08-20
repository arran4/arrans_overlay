EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-idf-kconfig"
SRC_URI="https://files.pythonhosted.org/packages/11/a8/ffa689bd9b360cfe559e5796bc1c750ebb500c53d855c80f47862a373afd/esp_idf_kconfig-3.12.0.tar.gz"
HOMEPAGE="https://pypi.org/project/esp-idf-kconfig/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/kconfiglib[${PYTHON_USEDEP}]
	dev-python/construct[${PYTHON_USEDEP}]
	dev-python/esp-pylib[${PYTHON_USEDEP}]
	dev-python/argcomplete[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
