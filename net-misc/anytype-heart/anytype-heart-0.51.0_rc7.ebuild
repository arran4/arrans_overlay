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
	# TODO: Must make Go dependency graph fully offline via proper go-module source/vendor inputs.
	# emake build-server
	einfo "Source build blocked pending offline Go dependencies."
}

src_install() {
	# dobin dist/server

	# insinto /usr/share/${PN}/pb
	# doins -r pb/*

	# insinto /usr/share/${PN}/pkg
	# doins -r pkg/*

	einfo "Source install blocked pending build step."
}
