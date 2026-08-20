EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-idf-size"
SRC_URI="https://files.pythonhosted.org/packages/95/7b/ddd861fde31e00463661a3d607952cd5142226f87955da9303008c3fa9d0/esp_idf_size-2.2.1.tar.gz"
HOMEPAGE="https://pypi.org/project/esp-idf-size/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/esp-pylib[${PYTHON_USEDEP}]
"

