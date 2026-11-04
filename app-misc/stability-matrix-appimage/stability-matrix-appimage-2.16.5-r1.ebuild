# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/app-misc-stability-matrix-appimage-update.yaml
EAPI=8

inherit desktop xdg-utils

DESCRIPTION="Multi-Platform Package Manager for Stable Diffusion"
HOMEPAGE="https://lykos.ai"
MY_URI="https://github.com/LykosAI/StabilityMatrix/releases/download/v${PV}"
SRC_URI="
	amd64? (
		${MY_URI}/StabilityMatrix-linux-x64.zip ->
			${P}-StabilityMatrix-linux-x64.zip
	)
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

RDEPEND="
	elibc_glibc? ( sys-libs/glibc )
	sys-devel/gcc
"
BDEPEND="app-arch/unzip"

pkg_pretend() {
	if ! use elibc_glibc; then
		die "Requires glibc; non-glibc profiles are unsupported."
	fi
}

src_unpack() {
	if use amd64; then
		unpack "${P}-StabilityMatrix-linux-x64.zip" \
			|| die "Can't unpack archive file"
	fi
	chmod a+x "StabilityMatrix.AppImage" || die "Can't chmod archive file"
	"./StabilityMatrix.AppImage" \
		--appimage-extract "zone.lykos.stabilitymatrix.desktop" \
		|| die "Failed to extract .desktop from appimage"
	"./StabilityMatrix.AppImage" --appimage-extract "*.png" \
		|| die "Failed to extract root icons from app image"
}

src_prepare() {
	sed -i \
		's:^Exec=.*:Exec=/opt/bin/StabilityMatrix.AppImage:' \
		'squashfs-root/zone.lykos.stabilitymatrix.desktop' || die
	eapply_user
}

src_install() {
	exeinto /opt/bin
	doexe "StabilityMatrix.AppImage" || die "Failed to install AppImage"
	domenu "squashfs-root/zone.lykos.stabilitymatrix.desktop"
	insinto /usr/share/pixmaps
	doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
	xdg_desktop_database_update
}
