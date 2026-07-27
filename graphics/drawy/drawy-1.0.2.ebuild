EAPI=8

KFMIN=6.19.0
QTMIN=6.10.0

inherit ecm

DESCRIPTION="Drawy is a lightweight infinite whiteboard built for simplicity and high performance"
HOMEPAGE="https://invent.kde.org/graphics/drawy"
SRC_URI="https://invent.kde.org/graphics/drawy/-/archive/v${PV}/drawy-v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="GPL-3"
SLOT="0"
IUSE="debug"
KEYWORDS="~amd64"

DEPEND="
        dev-qt/qtbase:6
        dev-qt/qtdeclarative:6
        kde-frameworks/kcoreaddons:6
        kde-frameworks/ki18n:6
        kde-frameworks/kxmlgui:6
        kde-frameworks/kconfig:6
        kde-frameworks/kconfigwidgets:6
        kde-frameworks/kcrash:6
        kde-frameworks/kwidgetsaddons:6
        kde-frameworks/kiconthemes:6
        kde-frameworks/syntax-highlighting:6
        sys-libs/zlib
        app-arch/zstd
"
RDEPEND="${DEPEND}"
BDEPEND="
        dev-qt/qttools:6[linguist]
        sys-devel/gettext
"
