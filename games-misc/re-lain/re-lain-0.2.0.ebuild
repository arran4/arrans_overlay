# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake desktop xdg

DESCRIPTION="Native Serial Experiments Lain PlayStation client"
HOMEPAGE="https://github.com/VandalsEmpire/lain-psx-decompiled-android"
MY_SOURCE_URI="https://github.com/VandalsEmpire/lain-psx-decompiled-android"
SRC_URI="
	${MY_SOURCE_URI}/archive/refs/tags/android-v${PV}.tar.gz -> ${P}.tar.gz
"
S="${WORKDIR}/lain-psx-decompiled-android-android-v${PV}"

LICENSE="MIT ZLIB Apache-2.0 CC0-1.0 WTFPL-2 public-domain"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-lang/python"
RDEPEND="
	media-libs/libsdl2[opengl,video]
	media-libs/openal
	virtual/opengl
"
DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/port"

src_configure() {
	local mycmakeargs=(
		-DLAIN_STATIC_DEPS=OFF
		-DLAIN_TRACE=OFF
	)
	cmake_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/lain"

	newicon -s scalable "${S}/docs/assets/save-icon.svg" "${PN}.svg"
	make_desktop_entry "lain" "Serial Experiments Lain" \
		"${PN}" "Game;AdventureGame;"

	doman "${FILESDIR}/lain.6"
	dodoc README.md port/PORTING.md port/MODDING.md
	dodoc -r thirdparty
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "This client does not contain game data."
	elog "Import your own raw 2352-byte/sector BIN/IMG disc dumps"
	elog "through the launcher (both discs are needed for the full game)."
	elog "See man lain(6) and README for controls and disc formats."
}
