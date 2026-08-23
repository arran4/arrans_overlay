# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV%-r*}"
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: freertos-gdb"
HOMEPAGE="https://pypi.org/project/freertos-gdb/"
SRC_URI="https://files.pythonhosted.org/packages/10/6c/656c7e3df6ae38cc456d780889304c9d77cebb7a1b9401314d668b5ef564/${PN}-${MY_PV}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
