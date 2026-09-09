# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Core engine for Anytype"
HOMEPAGE="https://github.com/anyproto/anytype-heart"
SRC_URI="https://github.com/anyproto/anytype-heart/archive/refs/tags/v${PV/_rc/-rc}.tar.gz -> ${P}.tar.gz
	# https://github.com/anyproto/anytype-heart/releases/download/v${PV/_rc/-rc}/${P}-deps.tar.xz"

LICENSE="ASAL"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-lang/go
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV/_rc/-rc}"

src_unpack() {
	go-module_src_unpack
}

src_prepare() {
	default
}

src_compile() {
	# Need to replicate network-config setup, tantivy check, govvv ldflags, nosigar nowatchdog tags
	# ego build -tags "nosigar nowatchdog" -ldflags "-X github.com/anyproto/anytype-heart/util/vcs.version=0.51.0-rc7" -o dist/server github.com/anyproto/anytype-heart/cmd/grpcserver
	einfo "Blocked pending fully offline Gentoo vendor tarball hosting."
}

src_install() {
	# newbin dist/server anytypeHelper

	# insinto /usr/share/${PN}/pb
	# doins -r pb/*

	# insinto /usr/share/${PN}/pkg
	# doins -r pkg/*
	einfo "Blocked pending build."
}
