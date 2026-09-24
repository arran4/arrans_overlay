# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Independent Total Annihilation engine reimplementation"
HOMEPAGE="https://nanolathe.gg/ https://github.com/nanolathe-gg/nanolathe"
MY_BASE_URL="https://github.com/arran4/fork-nanolathe/releases/download"
MY_ARCHIVE="fork-nanolathe_${PV}_linux_amd64.tar.gz"
SRC_URI="amd64? ( ${MY_BASE_URL}/v${PV}/${MY_ARCHIVE} -> ${P}.tar.gz )"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

RDEPEND="
	sys-libs/glibc
	media-libs/alsa-lib
	media-libs/libglvnd
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXxf86vm
"

S="${WORKDIR}"
QA_PREBUILT="/usr/bin/nanolathe"

src_install() {
	dobin nanolathe
}

pkg_postinst() {
	einfo "Nanolathe requires an existing Total Annihilation installation."
	einfo "Retail game data is not included with this package."
	einfo "Select it with: nanolathe --root /path/to/TotalAnnihilation"
}
