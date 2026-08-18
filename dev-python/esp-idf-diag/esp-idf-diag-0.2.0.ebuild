EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-idf-diag"
HOMEPAGE="https://pypi.org/project/esp-idf-diag/"
SRC_URI="https://files.pythonhosted.org/packages/5d/e8/ebb81a1a297dfc2c1d94dce2a412b1e956049baed8ddcaf0d61cc26a2e7a/esp_idf_diag-0.2.0.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/esp-pylib[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
