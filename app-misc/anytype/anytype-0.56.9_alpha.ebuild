# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg desktop

DESCRIPTION="Anytype Desktop application"
HOMEPAGE="https://github.com/anyproto/anytype-ts"
SRC_URI="https://github.com/anyproto/anytype-ts/archive/refs/tags/v${PV/_alpha/-alpha}.tar.gz -> ${P/_alpha/-alpha}.tar.gz"

LICENSE="ASAL"
SLOT="0"
KEYWORDS="~amd64"

# It also requires a fully offline JS node_modules closure.
# Do not bypass these rules to turn CI green.
DEPEND="
	~net-misc/anytype-heart-0.51.0_rc7
	dev-vcs/git
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/anytype-ts-${PV/_alpha/-alpha}"

src_unpack() {
	default
}

src_prepare() {
	default
}

src_compile() {
	einfo "Source build blocked pending offline JS dependencies and Electron prerequisite."
}

src_install() {
	einfo "Source install blocked pending build step."
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
