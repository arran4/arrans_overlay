EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: pygdbmi"
HOMEPAGE="https://pypi.org/project/pygdbmi/"
PYPI_PN="pygdbmi"
SRC_URI="https://files.pythonhosted.org/packages/2a/d0/d386ad42b12b90e60293c56a3b793910f34aa21c63f7ddc8a857e498d458/pygdbmi-0.11.0.0.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=""
DEPEND=""
