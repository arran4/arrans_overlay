# Copyright 2026 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 toolchain-funcs

DESCRIPTION="Native SDL2 port of the reconstructed Wing Commander II game"
HOMEPAGE="https://github.com/neuromancer/wc2-re"
EGIT_REPO_URI="https://github.com/neuromancer/wc2-re.git"
# Release tag v0.9.2 (do not follow a moving branch).
EGIT_COMMIT="7eb3f36bc24bf7dc29709bb3d1b2617cca32852e"
# The wibo submodule is needed for the separate MSVC reference build only.
EGIT_SUBMODULES=()

LICENSE="GPL-3 BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="virtual/pkgconfig"
DEPEND="
	dev-libs/lzo
	media-libs/libsdl2
"
RDEPEND="${DEPEND}"

src_compile() {
	local modern_cflags="${CFLAGS} -std=c11 -fno-common"
	modern_cflags+=" -Wno-return-type -Wno-return-mismatch"
	modern_cflags+=" -Wno-error=incompatible-pointer-types"
	modern_cflags+=" -Wno-int-conversion"

	# Upstream defaults to a sanitizer-instrumented development build.
	# Only build the native SDL2 target: the MSVC reference build fetches
	# proprietary toolchains, and the Slint GUI needs a separate Rust build.
	emake \
		MODERN_RELEASE=1 \
		MODERN_CC="$(tc-getCC)" \
		MODERN_CXX="$(tc-getCXX)" \
		MODERN_CFLAGS="${CFLAGS} -std=c11 -fno-common -Wno-return-type -Wno-return-mismatch -Wno-error=incompatible-pointer-types -Wno-int-conversion" \
		MODERN_CXXFLAGS="${CXXFLAGS} -std=c++11" \
		modern
}

src_test() {
	SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
		emake MODERN_RELEASE=1 modern-test
}

src_install() {
	dobin out-modern/wc2-modern
	dodoc README.md packaging/README-modern.txt
	newdoc third_party/ymfm/LICENSE YMFM-LICENSE
}

pkg_postinst() {
	einfo "Original Wing Commander II game data is not included."
	einfo "Run from the directory containing your WC2 game data, for example:"
	einfo "  cd /path/to/WC2 && wc2-modern --enhanced"
	einfo "This package builds the SDL2 CLI port, not the Slint GUI."
}
