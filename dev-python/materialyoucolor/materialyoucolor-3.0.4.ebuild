# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Material You color generation algorithms in Python"
HOMEPAGE="https://github.com/T-Dynamos/materialyoucolor-python https://pypi.org/project/materialyoucolor/"
SRC_URI="https://github.com/T-Dynamos/materialyoucolor-python/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${PN}-python-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND+="
	dev-python/pillow[${PYTHON_USEDEP}]
"
BDEPEND+="
	>=dev-python/pybind11-2.11.0[${PYTHON_USEDEP}]
"

distutils_enable_tests import-check
