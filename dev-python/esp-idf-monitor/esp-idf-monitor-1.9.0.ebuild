EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-idf-monitor"
HOMEPAGE="https://pypi.org/project/esp-idf-monitor/"
SRC_URI="https://files.pythonhosted.org/packages/7c/86/64a8984759506fbbbfce14ec981ec736420aeb79ffc964166a507e3be065/esp_idf_monitor-1.9.0.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/pyserial[${PYTHON_USEDEP}]
	dev-python/esp-coredump[${PYTHON_SINGLE_USEDEP}]
	dev-python/esp-idf-panic-decoder[${PYTHON_SINGLE_USEDEP}]
	dev-python/esp-pylib[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
