# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="TT2020 is an advanced, open source, hyperrealistic, multilingual typewriter font for a new decade."
HOMEPAGE="https://copypaste.wtf/TT2020/docs/"

SRC_URI="https://github.com/ctrlcctrlv/TT2020/archive/refs/tags/v${PV}.zip -> ${P}.zip"

LICENSE="SIL OPEN FONT LICENSE Version 1.1"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE=""
S="${WORKDIR}/TT2020-0.2.1/dist"

RESTRICT="binchecks strip"

FONT_SUFFIX="ttf woff2"
