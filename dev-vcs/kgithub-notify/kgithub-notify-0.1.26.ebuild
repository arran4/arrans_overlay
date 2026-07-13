# Manually maintained ebuild logic.
EAPI=8

KFMIN=6.0.0
QTMIN=6.6.2
ECM_TEST="true"
inherit ecm

DESCRIPTION="A sleek GitHub notification system tray application written natively in C++ using Qt6 and KDE Frameworks 6"
HOMEPAGE="https://github.com/arran4/kgithub-notify"
SRC_URI="https://github.com/arran4/kgithub-notify/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-qt/qtbase-${QTMIN}:6[gui,network,widgets,dbus]
	>=dev-qt/qtsvg-${QTMIN}:6
	>=kde-frameworks/kcoreaddons-${KFMIN}:6
	>=kde-frameworks/kconfigwidgets-${KFMIN}:6
	>=kde-frameworks/kxmlgui-${KFMIN}:6
	>=kde-frameworks/kwallet-${KFMIN}:6
	>=kde-frameworks/knotifications-${KFMIN}:6
	>=kde-frameworks/ki18n-${KFMIN}:6
	dev-libs/qtkeychain[qt6(+)]:=
"
DEPEND="${RDEPEND}
	test? ( >=dev-qt/qtbase-${QTMIN}:6[test] )
"
BDEPEND="
	>=kde-frameworks/extra-cmake-modules-${KFMIN}:0
	dev-qt/qttools:6
"
