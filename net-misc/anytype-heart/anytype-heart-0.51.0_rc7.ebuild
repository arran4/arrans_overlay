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
	# TODO: EGO_SUM is deprecated in EAPI 8, and generating a 38MB deps.tar.xz archive is outside the constraints of this environment.
	# The package must be hosted properly via standard Gentoo module-source distfile inputs.
	einfo "Source build blocked pending proper Go module vendor distfile"
}

src_install() {
	einfo "Source install blocked pending build step"
}
