# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Core engine for Anytype"
HOMEPAGE="https://github.com/anyproto/anytype-heart"
SRC_URI="https://github.com/anyproto/anytype-heart/archive/refs/tags/v${PV/_rc/-rc}.tar.gz -> ${P}.tar.gz"

LICENSE="ASAL"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-lang/go
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV/_rc/-rc}"

src_unpack() {
	default
}

src_prepare() {
	default
}

src_compile() {
	# We will assume EGO_SUM or vendor logic is provided out of band for offline build,
	# but for the draft we just block as requested if offline is truly missing.
	einfo "Source build blocked pending offline Go dependencies."
}

src_install() {
	einfo "Source install blocked pending build step."
}
