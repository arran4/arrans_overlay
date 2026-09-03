# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generator: .github/workflows/net-misc-kmagmux-update.yaml

EAPI=8

ECM_TEST="true"
inherit ecm

DESCRIPTION="Torrent file and Magnet link handler routing to programs/services"
HOMEPAGE="https://github.com/arran4/KMagMux"
U="github.com/arran4/KMagMux/archive/refs/tags"
SRC_URI="https://${U}/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/KMagMux-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
DEPEND="
	dev-qt/qtbase:6[dbus,gui,network,widgets,concurrent]
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kxmlgui:6
	kde-frameworks/kwallet:6
"
RDEPEND="${DEPEND}"

src_prepare() {
	ecm_src_prepare
}

