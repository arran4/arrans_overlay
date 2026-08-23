# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python dependency for ESP-IDF: esp-idf-panic-decoder"
HOMEPAGE="https://pypi.org/project/esp-idf-panic-decoder/"
SRC_URI="https://files.pythonhosted.org/packages/da/f1/e4d6170a51e15afd27660992fbd2a4728cf401750ebb388b1ce035d95025/esp_idf_panic_decoder-1.5.0.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/pyelftools[${PYTHON_USEDEP}]
	dev-python/pyparsing[${PYTHON_USEDEP}]
"
