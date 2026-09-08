# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# Pinned commit needed for gui-apps/caelestia-shell-2.4.0
M3SHAPES_REV="32ad9ce328bb77ed349b40a3be10ee9ea610b8ab"

DESCRIPTION="Material 3 Shapes QML module"
HOMEPAGE="https://github.com/soramanew/m3shapes"
SRC_URI="
	https://github.com/soramanew/m3shapes/archive/${M3SHAPES_REV}.tar.gz
	-> ${PN}-${PV}.tar.gz
"

S="${WORKDIR}/${PN}-${M3SHAPES_REV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=dev-qt/qtbase-6.8:6
	>=dev-qt/qtdeclarative-6.8:6
	>=dev-qt/qtshadertools-6.8:6
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-qt/qtshadertools-6.8:6
"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/"
		-DINSTALL_QMLDIR=usr/lib64/qt6/qml
		-DM3SHAPES_BUILD_EXAMPLES=OFF
	)
	cmake_src_configure
}
