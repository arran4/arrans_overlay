# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="Ncurses widget toolkit used by VWM"
HOMEPAGE="https://github.com/TragicWarrior/libviper"
EGIT_REPO_URI="https://github.com/TragicWarrior/libviper.git"

LICENSE="GPL-2+"
SLOT="0/7"
KEYWORDS=""
IUSE="gpm static-libs"

RDEPEND="
	sys-libs/ncurses:0=[unicode]
	gpm? ( sys-libs/gpm )
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-9999-libdir.patch"
)

src_configure() {
	local mycmakeargs=(
		-DCMAKE_DISABLE_FIND_PACKAGE_GPM="$(usex gpm OFF ON)"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if ! use static-libs; then
		rm "${ED}/usr/$(get_libdir)/libvdk.a" || die
	fi

	dodoc README.md CHANGELOG
}
