# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KFMIN=6.0.0
QTMIN=6.6.2
inherit ecm

DESCRIPTION="Torrent file and Magnet link handler for routing to programs / services."
HOMEPAGE="https://github.com/arran4/KMagMux"
SRC_URI="https://github.com/arran4/KMagMux/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3.0-or-later"
SLOT="0"
KEYWORDS="~amd64"
DEPEND="
	dev-qt/qtbase:6[dbus,gui,network,widgets,concurrent]
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kxmlgui:6
	dev-libs/qtkeychain:=[qt6]
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

S="${WORKDIR}/KMagMux-${PV}"
