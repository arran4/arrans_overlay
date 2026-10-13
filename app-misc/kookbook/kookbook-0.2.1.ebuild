EAPI=8

inherit cmake

DESCRIPTION="Cookbook creator (KDE Utility)"
HOMEPAGE="https://invent.kde.org/utilities/kookbook"
SRC_URI="https://invent.kde.org/utilities/kookbook/-/archive/v${PV}/kookbook-v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtprintsupport:5
	dev-qt/qtdeclarative:5
	app-text/discount
"
RDEPEND="${DEPEND}"
BDEPEND="kde-frameworks/extra-cmake-modules:0"

S="${WORKDIR}/${PN}-v${PV}"*
