# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Manually maintained KDE CMake source ebuild. Release updates via
# .github/workflows/app-misc-klookup-update.yml (not current.config).
EAPI=8

inherit ecm xdg

DESCRIPTION="Extensible multi-provider lookup application for KDE Plasma"
HOMEPAGE="https://github.com/arran4/klookup"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/arran4/klookup.git"
else
	SRC_URI="https://github.com/arran4/klookup/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3+"
SLOT="0"

DEPEND="
	dev-qt/qtbase:6[dbus,gui,network,widgets]
	dev-qt/qtdeclarative:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kdbusaddons:6
	kde-frameworks/kglobalaccel:6
	kde-frameworks/ki18n:6
	kde-frameworks/knotifications:6
	kde-frameworks/krunner:6
	kde-frameworks/kwallet:6
	kde-frameworks/kwidgetsaddons:6
	kde-frameworks/kxmlgui:6
	sys-libs/zlib
"
RDEPEND="${DEPEND}"
BDEPEND="
	kde-frameworks/extra-cmake-modules:0
"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
	)
	ecm_src_configure
}
