# Copyright 2024-2025 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3

DESCRIPTION="KDE Plasma 6 lookup tool with extensible search providers and KRunner integration"
HOMEPAGE="https://github.com/arran4/klookup"
EGIT_REPO_URI="https://github.com/arran4/klookup.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	virtual/pkgconfig
"
DEPEND="
	dev-qt/qtbase:6[dbus,gui,network,widgets]
	dev-qt/qtdeclarative:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kconfig:6
	kde-frameworks/kdbusaddons:6
	kde-frameworks/kglobalaccel:6
	kde-frameworks/ki18n:6
	kde-frameworks/knotifications:6
	kde-frameworks/krunner:6
	kde-frameworks/kwallet:6
	kde-frameworks/kwidgetsaddons:6
	kde-frameworks/kxmlgui:6
"
RDEPEND="${DEPEND}"
