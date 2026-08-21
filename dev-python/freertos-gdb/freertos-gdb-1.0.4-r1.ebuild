EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 # pypi

DESCRIPTION="Python dependency for ESP-IDF: freertos-gdb"
HOMEPAGE="https://pypi.org/project/freertos-gdb/"

# Use SRC_URI since PYPI_PN forces invalid name normalization and we always end up
# with freertos_gdb which is wrong.
#PYPI_PN="freertos-gdb"
SRC_URI="https://files.pythonhosted.org/packages/source/f/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
