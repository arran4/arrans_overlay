# Generated via:
# .github/workflows/net-misc-kmagmux-update.yaml

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
	dev-qt/qtbase:6[concurrent,gui,network,widgets,test]
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kwallet:6
	kde-frameworks/kxmlgui:6
"
RDEPEND="${DEPEND}"

src_prepare() {
	ecm_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
	)
	ecm_src_configure
}
