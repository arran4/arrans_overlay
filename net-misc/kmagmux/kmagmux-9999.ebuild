# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ECM_TEST="true"
inherit ecm git-r3

DESCRIPTION="Torrent file and Magnet link handler routing to programs/services"
HOMEPAGE="https://github.com/arran4/KMagMux"
EGIT_REPO_URI="https://github.com/arran4/KMagMux.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
DEPEND="
	dev-qt/qtbase:6[dbus,gui,network,widgets,concurrent]
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kxmlgui:6
	kde-plasma/plasma-workspace:6
	kde-frameworks/kio:6
	kde-frameworks/knotifications:6
	kde-frameworks/kwallet:6
"
RDEPEND="${DEPEND}"

src_install() {
	ecm_src_install
}
