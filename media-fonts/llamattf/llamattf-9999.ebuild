# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A font containing a large language model and inference engine."
HOMEPAGE="https://github.com/fuglede/llama.ttf"
SRC_URI="https://github.com/fuglede/llama.ttf/raw/master/llamattf/llama.ttf -> llama-${PV}.ttf"
S="${DISTDIR}"

LICENSE="unknown-license"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE=""

RESTRICT="binchecks strip"

FONT_SUFFIX="ttf"
