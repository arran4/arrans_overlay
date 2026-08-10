# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KDE_ORG_CATEGORY="games"
KDE_ORG_NAME="kretro"
KDE_ORG_COMMIT="v${PV}"
inherit ecm kde.org

DESCRIPTION="Libretro Emulation Frontend for Plasma"

LICENSE="BSD-3-Clause"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

DEPEND="
	>=dev-qt/qtbase-6.6:6=[gui,widgets,network]
	>=dev-qt/qtdeclarative-6.6:6=
	>=dev-qt/qtmultimedia-6.6:6=
	>=dev-qt/qtsvg-6.6:6=
	>=kde-frameworks/kirigami-6.8.0:6=
	>=kde-frameworks/kcoreaddons-6.8.0:6=
	>=kde-frameworks/kconfig-6.8.0:6=
	>=kde-frameworks/ki18n-6.8.0:6=
	>=kde-plasma/kirigami-addons-1.0.0:6=
	media-libs/libsdl3:=
"
RDEPEND="${DEPEND}"
