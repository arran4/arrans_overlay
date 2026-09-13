# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Generated via:
# .github/workflows/net-misc-kmagmux-update.yaml

inherit ecm

DESCRIPTION="Torrent file and Magnet link handler for programs/services"
HOMEPAGE="https://github.com/arran4/KMagMux"
SRC_URI="https://github.com/arran4/KMagMux/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/KMagMux-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

DEPEND="dev-qt/qtbase:6[concurrent,gui,network,test,widgets]"
DEPEND+=" kde-frameworks/kcoreaddons:6 kde-frameworks/ki18n:6"
DEPEND+=" kde-frameworks/kwallet:6 kde-frameworks/kxmlgui:6"
RDEPEND="${DEPEND}"
BDEPEND="dev-qt/qttools:6[linguist]"
BDEPEND+=" kde-frameworks/extra-cmake-modules:0 virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
	)
	ecm_src_configure
}
