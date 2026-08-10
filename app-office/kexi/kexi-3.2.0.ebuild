EAPI=8

inherit ecm

DESCRIPTION="A visual database applications creator"
HOMEPAGE="https://kexi-project.org/ https://invent.kde.org/office/kexi"
SRC_URI="https://download.kde.org/stable/${PN}/src/${P}.tar.xz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-db/kdb:0
	dev-db/kproperty:0
	dev-db/kreport:0
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	kde-frameworks/karchive:5
	kde-frameworks/kconfig:5
	kde-frameworks/kconfigwidgets:5
	kde-frameworks/kcoreaddons:5
	kde-frameworks/kcrash:5
	kde-frameworks/ki18n:5
	kde-frameworks/kiconthemes:5
	kde-frameworks/kio:5
	kde-frameworks/kitemviews:5
	kde-frameworks/ktexteditor:5
	kde-frameworks/ktextwidgets:5
	kde-frameworks/kwidgetsaddons:5
	kde-frameworks/kxmlgui:5
"
RDEPEND="${DEPEND}"

src_prepare() {
	ecm_src_prepare
}
