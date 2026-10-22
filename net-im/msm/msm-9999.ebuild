# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo desktop git-r3 xdg

DESCRIPTION="MSN-Messenger-style desktop client for Matrix"
HOMEPAGE="https://github.com/DMJC/msm"
EGIT_REPO_URI="https://github.com/DMJC/msm.git"

LICENSE="GPL-3+"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS=""

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
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_install() {
	cargo_src_install
	domenu data/com.matrixmessenger.Msm.desktop
	doicon -s scalable data/icons/hicolor/scalable/apps/com.matrixmessenger.Msm.svg
}
