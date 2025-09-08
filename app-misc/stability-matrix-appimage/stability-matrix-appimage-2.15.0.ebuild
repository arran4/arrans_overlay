# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-stability-matrix-appimage-update.yaml
EAPI=8
DESCRIPTION="Multi-Platform Package Manager for Stable Diffusion"
HOMEPAGE="https://lykos.ai"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND="sys-libs/glibc sys-libs/zlib "
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="
  amd64? ( https://github.com/LykosAI/StabilityMatrix/releases/download/v2.15.0/StabilityMatrix-linux-x64.zip -> ${P}-StabilityMatrix-linux-x64.zip )
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-StabilityMatrix-linux-x64.zip" || die "Can't unpack archive file"
  fi
  if use amd64; then
    mv "StabilityMatrix.AppImage" "StabilityMatrix.AppImage"  || die "Can't move archived file"
  fi
  chmod a+x "StabilityMatrix.AppImage"  || die "Can't chmod archive file"
  "./StabilityMatrix.AppImage" --appimage-extract "zone.lykos.stabilitymatrix.desktop" || die "Failed to extract .desktop from appimage"
  "./StabilityMatrix.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/StabilityMatrix.AppImage:' 'squashfs-root/zone.lykos.stabilitymatrix.desktop'
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "StabilityMatrix.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/zone.lykos.stabilitymatrix.desktop" || die "Failed to install desktop file"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

