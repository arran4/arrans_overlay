EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: idf-component-manager"
SRC_URI="https://files.pythonhosted.org/packages/07/34/5abb9907455c17a183914358c43a688a169288dbea1e4be85a1414eb8fa2/idf_component_manager-3.1.0.tar.gz"
HOMEPAGE="https://pypi.org/project/idf-component-manager/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
