# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit ecm git-r3

DESCRIPTION="Torrent file and Magnet link handler for routing to programs / services."
HOMEPAGE="https://github.com/arran4/KMagMux"
EGIT_REPO_URI="https://github.com/arran4/KMagMux.git"

LICENSE="GPL-3.0-or-later"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	dev-qt/qtbase:6[dbus,gui,network,widgets,concurrent]
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kxmlgui:6
	dev-libs/qtkeychain:=[qt6]
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-qt/qttools:6[linguist]
	virtual/pkgconfig
	kde-frameworks/extra-cmake-modules:0
"
