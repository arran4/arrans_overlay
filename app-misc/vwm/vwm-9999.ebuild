# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Virtual window manager for the terminal"
HOMEPAGE="https://github.com/TragicWarrior/vwm"
EGIT_REPO_URI="https://github.com/TragicWarrior/vwm.git"

LICENSE="GPL-2+ LGPL-2.1+ BSD MIT BitstreamVera"
SLOT="0"
KEYWORDS=""
IUSE="dtach gpm xclip"

DEPEND="
	>=dev-libs/libviper-7.2.0
	media-libs/freetype
	net-print/cups
	sys-libs/ncurses:0=[unicode]
	sys-libs/zlib
	gpm? ( sys-libs/gpm )
"
RDEPEND="
	${DEPEND}
	dtach? ( app-misc/dtach )
	xclip? ( x11-misc/xclip )
"

PATCHES=(
	"${FILESDIR}/${PN}-9999-system-libraries.patch"
)

src_unpack() {
	EGIT_REPO_URI="https://github.com/TragicWarrior/vwm.git"
	EGIT_CHECKOUT_DIR="${S}"
	git-r3_src_unpack

	# TragicWarrior/libvterm is unrelated to Gentoo's dev-libs/libvterm,
	# despite installing the same library/header names.  Keep it private to
	# this build so both implementations can coexist on a Gentoo system.
	EGIT_REPO_URI="https://github.com/TragicWarrior/libvterm.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}/libvterm"
	git-r3_src_unpack
}

src_prepare() {
	cmake_src_prepare

	# Respect the user's optimisation flags when building the private
	# libvterm copy; upstream otherwise appends -O2 after CFLAGS.
	sed -i \
		-e 's/ -O2 -std=c99 -Wall -fPIC -fno-plt/ -std=c99 -Wall -fPIC/' \
		"${WORKDIR}/libvterm/CMakeLists.txt" || die
}

src_configure() {
	# Configure the conflicting libvterm implementation separately and only
	# consume its static archive.  Nothing from it is installed system-wide.
	(
		S="${WORKDIR}/libvterm"
		BUILD_DIR="${WORKDIR}/libvterm-build"
		local mycmakeargs=(
			-DDEFINE_CURSES=OFF
			-DENABLE_BACKTRACE=OFF
			-DBUILD_TESTS=OFF
		)
		cmake_src_configure
	)

	local mycmakeargs=(
		-DCMAKE_DISABLE_FIND_PACKAGE_GPM="$(usex gpm OFF ON)"
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DVTERM_INCLUDE_DIR="${WORKDIR}/libvterm"
		-DVTERM_LIBRARY="${WORKDIR}/libvterm-build/libvterm.a"
	)
	cmake_src_configure
}

src_compile() {
	(
		BUILD_DIR="${WORKDIR}/libvterm-build"
		cmake_build vterm-static
	)

	cmake_src_compile
}

src_install() {
	cmake_src_install
	dodoc README.md CHANGELOG NEWS.md
}
