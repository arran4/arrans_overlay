# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..13} )
inherit distutils-r1

DESCRIPTION="A terminal UI for SQL databases"
HOMEPAGE="https://github.com/Maxteabag/sqlit"
SRC_URI="https://github.com/Maxteabag/sqlit/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/textual-6.10.0[${PYTHON_USEDEP}]
	>=dev-python/textual-fastdatatable-0.14.0[${PYTHON_USEDEP}]
	>=dev-python/pyperclip-1.8.2[${PYTHON_USEDEP}]
	>=dev-python/keyring-24.0.0[${PYTHON_USEDEP}]
	>=dev-python/docker-7.0.0[${PYTHON_USEDEP}]
	>=dev-python/sqlparse-0.5.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
"

src_configure() {
	export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
	distutils-r1_src_configure
}
