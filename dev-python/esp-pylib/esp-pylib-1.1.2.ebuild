EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-pylib"
HOMEPAGE="https://pypi.org/project/esp-pylib/"
SRC_URI="https://files.pythonhosted.org/packages/c2/07/9ac0f09cdb591d3daae5ae071c14c6cf7015e13ccc59f3f6e00f67dda641/esp_pylib-1.1.2.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/rich[${PYTHON_USEDEP}]
"
