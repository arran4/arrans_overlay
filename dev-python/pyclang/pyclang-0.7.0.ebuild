EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: pyclang"
HOMEPAGE="https://pypi.org/project/pyclang/"
SRC_URI="https://files.pythonhosted.org/packages/source/p/pyclang/pyclang-0.7.0.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
