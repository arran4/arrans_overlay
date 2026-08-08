EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: freertos-gdb"
HOMEPAGE="https://pypi.org/project/freertos-gdb/"
PYPI_PN="freertos_gdb"
SRC_URI="https://files.pythonhosted.org/packages/source/f/freertos-gdb/freertos-gdb-1.0.4.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
