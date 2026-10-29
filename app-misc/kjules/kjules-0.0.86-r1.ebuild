# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/app-misc-kjules-update.yaml
EAPI=8

ECM_TEST="forceoptional"
inherit xdg ecm

DESCRIPTION="kjules KDE application"
HOMEPAGE="https://github.com/arran4/kjules"
SRC_URI="
	https://github.com/arran4/kjules/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

DEPEND="
	dev-qt/qtbase:6[gui,network,widgets]
	kde-frameworks/karchive:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kdbusaddons:6
	kde-frameworks/kglobalaccel:6
	kde-frameworks/ki18n:6
	kde-frameworks/knotifications:6
	kde-frameworks/kwallet:6
	kde-frameworks/kwidgetsaddons:6
	kde-frameworks/kwindowsystem:6
	kde-frameworks/kxmlgui:6
	test? (
		kde-frameworks/kcolorscheme:6
		kde-frameworks/kconfigwidgets:6
		kde-frameworks/kguiaddons:6
	)
"
RDEPEND="${DEPEND}"

src_prepare() {
	ecm_src_prepare
	sed -i -e \
		's/KDE_INSTALL_KXMLGUI6DIR/KDE_INSTALL_KXMLGUIDIR/g' \
		CMakeLists.txt || die
	cmake_comment_add_subdirectory bench
}

src_configure() {
	ecm_src_configure
}
