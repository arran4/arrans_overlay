# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-misc-kmagmux-update.yaml
EAPI=8

inherit ecm

DESCRIPTION="Torrent file and Magnet link handler for routing to programs / services."
HOMEPAGE="https://github.com/arran4/KMagMux"
SRC_URI="https://github.com/arran4/KMagMux/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${P}"

LICENSE="GPL-3.0-or-later"
SLOT="0"
IUSE="debug"
KEYWORDS="~amd64"

DEPEND="
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kxmlgui:6
	kde-plasma/plasma-workspace:6
	kde-frameworks/kio:6
	kde-frameworks/knotifications:6
	kde-frameworks/kwallet:6
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
