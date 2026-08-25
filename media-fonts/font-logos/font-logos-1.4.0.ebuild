# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Icon font containing logos of Linux distributions and open source software"
HOMEPAGE="https://github.com/lukas-w/font-logos"
SRC_URI="https://github.com/lukas-w/font-logos/releases/download/v${PV}/${P}.zip"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86"

BDEPEND="app-arch/unzip"

FONT_SUFFIX="ttf"
FONT_S="${S}/assets"

DOCS=( README.md )
