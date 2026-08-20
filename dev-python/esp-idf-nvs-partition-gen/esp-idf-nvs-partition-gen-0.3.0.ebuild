EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-idf-nvs-partition-gen"
HOMEPAGE="https://pypi.org/project/esp-idf-nvs-partition-gen/"
SRC_URI="https://files.pythonhosted.org/packages/84/c9/50173df772d5a0fffda5398247af1f8441b4378bbe45723fbccffbb0dd94/esp_idf_nvs_partition_gen-0.3.0.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/esp-pylib[${PYTHON_USEDEP}]
	dev-python/rich-click[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
"
