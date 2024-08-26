# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="The font that powers Excalidraw"
HOMEPAGE="https://virgil.excalidraw.com/"
SRC_URI="https://github.com/excalidraw/virgil/raw/main/Virgil.woff2 -> virgil.woff2"
S="${DISTDIR}"

LICENSE="unknown-license"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE=""

RESTRICT="binchecks strip"

FONT_SUFFIX="woff2"
