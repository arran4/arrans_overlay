# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV%-r*}"
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1

DESCRIPTION="Python dependency for ESP-IDF: freertos-gdb"
HOMEPAGE="https://pypi.org/project/freertos-gdb/"
SRC_URI="https://files.pythonhosted.org/packages/source/f/${PN}/${PN}-${MY_PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}/${PN}-${MY_PV}"

RDEPEND=""
