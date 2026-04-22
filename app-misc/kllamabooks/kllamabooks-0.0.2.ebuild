# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

DESCRIPTION="An AI LLM Desktop Client and Document Editor for KDE/Qt"
HOMEPAGE="https://github.com/arran4/kllamabooks"
SRC_URI="https://github.com/arran4/kllamabooks/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-qt/qtbase:6[dbus,gui,network,widgets]
	dev-qt/qtsvg:6
	kde-frameworks/kconfigwidgets:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kwallet:6
	kde-frameworks/kxmlgui:6
	dev-db/sqlcipher
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-qt/qttools:6[linguist]
	virtual/pkgconfig
	kde-frameworks/extra-cmake-modules:0
"
