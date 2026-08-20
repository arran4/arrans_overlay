# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python Reed Solomon encoder/decoder"
HOMEPAGE="
	https://github.com/tomerfiliba/reedsolomon/
	https://pypi.org/project/reedsolo/
"
SRC_URI="https://files.pythonhosted.org/packages/source/r/reedsolo/reedsolo-1.7.0.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( Unlicense MIT-0 )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="+native-extensions"

BDEPEND="
	>=dev-python/cython-3[${PYTHON_USEDEP}]
"

python_compile() {
	local DISTUTILS_ARGS=()
	if use native-extensions && [[ ${EPYTHON} != pypy3 ]] ; then
		DISTUTILS_ARGS+=(
			--cythonize
		)
	fi
	distutils-r1_python_compile
}
