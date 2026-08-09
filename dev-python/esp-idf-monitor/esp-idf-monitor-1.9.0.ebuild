EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-idf-monitor"
SRC_URI="https://files.pythonhosted.org/packages/7c/86/64a8984759506fbbbfce14ec981ec736420aeb79ffc964166a507e3be065/esp_idf_monitor-1.9.0.tar.gz"
HOMEPAGE="https://pypi.org/project/esp-idf-monitor/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
