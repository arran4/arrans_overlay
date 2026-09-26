# Copyright 2026 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Open-source engine for Total Annihilation: Kingdoms"
HOMEPAGE="https://openkingdoms.net/"
SRC_URI="
	https://github.com/OpenKingdoms/OpenKingdoms/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
"
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
	einfo "OpenKingdoms provides the engine only; original game data is required."
	einfo "Use a directory containing your own TA: Kingdoms .hpi archives."
	einfo "Maps, Music and Movies subdirectories may be kept there as well."
	einfo
	einfo "To select the directory explicitly, run:"
	einfo "  openkingdoms --game-dir /path/to/Total\ Annihilation\ Kingdoms"
	einfo "The selected directory is remembered for later runs."
	einfo
	einfo "You can also set TAK_GAME_DIR to the game directory."
	einfo "Without an explicit setting, OpenKingdoms searches for game data in:"
	einfo "  a previously remembered directory"
	einfo "  a game directory beside the executable"
	einfo "  ~/Games/Total Annihilation Kingdoms"
	einfo "  ~/.wine/drive_c/GOG Games/Total Annihilation Kingdoms"
	einfo "and standard GOG/Cavedog installation paths on Windows."
	einfo
	einfo "The directory must directly contain at least one .hpi archive."
	einfo "TAK_DATA_DIR is for extracted development data, not the game archives."
	einfo "See the installed ASSETS.md documentation for further details."
}
