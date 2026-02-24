# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="A GitHub notification tool for KDE/Qt"
HOMEPAGE="https://github.com/arran4/kgithub-notify"
SRC_URI="https://github.com/arran4/kgithub-notify/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-qt/qtsvg:5
	kde-frameworks/knotifications:5
	kde-frameworks/kwallet:5
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-qt/linguist-tools:5
	virtual/pkgconfig
	kde-frameworks/extra-cmake-modules:5
"
