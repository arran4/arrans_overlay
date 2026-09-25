# Copyright 2026 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Open-source engine for Total Annihilation: Kingdoms"
HOMEPAGE="https://openkingdoms.net/"
SRC_URI="https://github.com/OpenKingdoms/OpenKingdoms/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OpenKingdoms-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	media-libs/libsdl2
	media-video/ffmpeg
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
		-DTAK_GAME_DIR=
		-DTAK_DATA_DIR="${EPREFIX}/usr/share/${PN}"
	)
	cmake_src_configure
}

src_compile() {
	# Upstream defines developer test executables unconditionally.
	# Build only the game target; data-dependent tests need original assets.
	cmake_build tak-re
}

src_install() {
	newbin "${BUILD_DIR}/src/tak-re" openkingdoms
	dodoc README.md docs/ASSETS.md
}

pkg_postinst() {
	einfo "OpenKingdoms provides the engine only, not the original game data."
	einfo "Install your own Total Annihilation: Kingdoms files and run:"
	einfo "  openkingdoms --game-dir /path/to/your/game"
	einfo "Alternatively, set TAK_GAME_DIR to the game directory."
}
