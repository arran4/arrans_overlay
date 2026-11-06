# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo desktop xdg

DESCRIPTION="MSN-Messenger-style desktop client for Matrix"
HOMEPAGE="https://github.com/DMJC/msm"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/DMJC/msm.git"
else
	SRC_URI="https://github.com/DMJC/msm/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
		${CARGO_CRATE_URIS}"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD MIT"
SLOT="0"

DEPEND="
	x11-libs/gtk+:3
	media-libs/opus
	dev-db/sqlite:3
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else
		cargo_src_unpack
	fi
}

src_configure() {
	cargo_src_configure
}

src_install() {
	cargo_src_install
	domenu data/com.matrixmessenger.Msm.desktop
	local icon_path="data/icons/hicolor/scalable/apps"
	icon_path+="/com.matrixmessenger.Msm.svg"
	newicon -s scalable "${icon_path}" com.matrixmessenger.Msm.svg
}
