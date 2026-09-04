# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# https://github.com/arran4/arrans_overlay/blob/main\
# /.github/workflows/net-misc-kmagmux-update.yaml
EAPI=8

inherit ecm

DESCRIPTION="Torrent file and Magnet link handler for programs/services."
HOMEPAGE="https://github.com/arran4/KMagMux"
SRC_URI="https://github.com/arran4/KMagMux/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
IUSE="debug"
KEYWORDS="~amd64"

DEPEND="
	dev-qt/qtbase:6[concurrent,gui,network,widgets]
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kwallet:6
	kde-frameworks/kxmlgui:6
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-qt/qttools:6[linguist]
	kde-frameworks/extra-cmake-modules:0
	virtual/pkgconfig
"

src_prepare() {
	ecm_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
	)
	ecm_src_configure
}
