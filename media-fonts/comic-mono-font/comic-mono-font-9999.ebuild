# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION=" A legible monospace font... the very typeface you’ve been trained to recognize since childhood."
HOMEPAGE="https://github.com/dtinth/comic-mono-font/"
SRC_URI="
	https://github.com/dtinth/comic-mono-font/archive/refs/heads/master.zip -> ${PV}.zip
"
S="${DISTDIR}/comic-mono-font-master"

LICENSE="MIT License"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE=""

RESTRICT="binchecks strip"

FONT_SUFFIX="ttf"
