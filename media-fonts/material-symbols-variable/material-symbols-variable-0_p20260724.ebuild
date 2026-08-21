# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Google Material Symbols variable fonts (Outlined, Rounded, Sharp)"
HOMEPAGE="https://fonts.google.com/icons https://github.com/google/material-design-icons"

# Upstream does not publish versioned releases of the variable fonts;
# pin to a known commit on master under variablefont/. Bump PV to the
# commit date (YYYYMMDD) and update MDI_COMMIT to bump.
MDI_COMMIT="481507587f1bdfe712939398c4dc0ecc2079ea7c"
MDI_BASE="https://raw.githubusercontent.com/google/material-design-icons/${MDI_COMMIT}/variablefont"

SRC_URI="
	${MDI_BASE}/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf
		-> MaterialSymbolsOutlined-${PV}.ttf
	${MDI_BASE}/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf
		-> MaterialSymbolsRounded-${PV}.ttf
	${MDI_BASE}/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf
		-> MaterialSymbolsSharp-${PV}.ttf
"

S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# These are individual font files; nothing to mirror, nothing to strip.
RESTRICT="mirror binchecks strip"

FONT_SUFFIX="ttf"

src_unpack() {
	# Files are downloaded directly to DISTDIR with versioned names;
	# install them under their canonical (un-suffixed) basenames.
	cp "${DISTDIR}/MaterialSymbolsOutlined-${PV}.ttf" \
		"${S}/MaterialSymbolsOutlined.ttf" || die
	cp "${DISTDIR}/MaterialSymbolsRounded-${PV}.ttf" \
		"${S}/MaterialSymbolsRounded.ttf" || die
	cp "${DISTDIR}/MaterialSymbolsSharp-${PV}.ttf" \
		"${S}/MaterialSymbolsSharp.ttf" || die
}

src_install() {
	font_src_install
}
