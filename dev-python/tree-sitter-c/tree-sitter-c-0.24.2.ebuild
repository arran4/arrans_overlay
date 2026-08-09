EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: tree-sitter-c"
SRC_URI="https://files.pythonhosted.org/packages/a6/c9/3834f3d9278251aea7312274971bc4c45b17aec2490fd4b884d93bd7019a/tree_sitter_c-0.24.2.tar.gz"
HOMEPAGE="https://pypi.org/project/tree-sitter-c/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
