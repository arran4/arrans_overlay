# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Rapid application development framework for Python"
HOMEPAGE="https://github.com/Textualize/textual https://pypi.org/project/textual/"
SRC_URI="https://files.pythonhosted.org/packages/1f/b6/59b1de04bb4dca0f21ed7ba0b19309ed7f3f5de4396edf20cc2855e53085/textual-1.0.0.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/markdown-it-py[${PYTHON_USEDEP}]
	dev-python/linkify-it-py[${PYTHON_USEDEP}]
	dev-python/mdit-py-plugins[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	dev-python/platformdirs[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"
