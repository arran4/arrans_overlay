# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A TTF font that hides what you're typing from AI. Type a message where each letter contains a decoy."
HOMEPAGE="https://www.mixfont.com/experiments/decoy-font"
SRC_URI="https://static.mixfont.com/assets/20260714-232642-decoyfont-htoqkd3x.ttf -> ${P}.ttf"

LICENSE="unknown-license"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86"
IUSE=""

S="${WORKDIR}"

RESTRICT="binchecks strip"

FONT_SUFFIX="ttf"

src_unpack() {
	cp "${DISTDIR}/${A}" "${S}/" || die
}
