EAPI=8

inherit cmake git-r3

DESCRIPTION="Open-source engine for Total Annihilation: Kingdoms"
HOMEPAGE="https://openkingdoms.net/ https://github.com/OpenKingdoms/OpenKingdoms"

# Pin the v0.3.3 release to its commit, rather than following a mutable branch.
# Fetch from Git until a release source distfile can be manifested.
EGIT_REPO_URI="https://github.com/OpenKingdoms/OpenKingdoms.git"
EGIT_COMMIT="78843bf708ac4d5f1f2e12607fcef01929f70dfb"

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
	# Upstream defines developer test executables unconditionally; build the game only.
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
