# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-stability-matrix-appimage-update.yaml
EAPI=8
DESCRIPTION="Multi-Platform Package Manager for Stable Diffusion"
HOMEPAGE="https://lykos.ai"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="https://github.com/LykosAI/StabilityMatrix/releases/download/v${PV}/StabilityMatrix-linux-x64.zip -> $P.zip"

src_unpack() {
  unzip "${DISTDIR}/${A}" -d ${WORKDIR} || die "Can't unzip archive file"
  chmod a+x ./StabilityMatrix.AppImage || die "Can't chmod +x AppImage"
  ./StabilityMatrix.AppImage --appimage-extract zone.lykos.stabilitymatrix.desktop || die "Can't extract .desktop file from AppImage"
  ./StabilityMatrix.AppImage --appimage-extract usr/share/icons || die "Can't extract icons from AppImage"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/usr/bin/StabilityMatrix.AppImage:' squashfs-root/zone.lykos.stabilitymatrix.desktop
  sed -i 's:^TryExec=.*:TryExec=/usr/bin/StabilityMatrix.AppImage:' squashfs-root/zone.lykos.stabilitymatrix.desktop
  find squashfs-root -type d -exec rmdir -p {} \; 
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm -v {} \; 
  eapply_user
}

src_install() {
  dobin "${WORKDIR}/StabilityMatrix.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "${WORKDIR}/squashfs-root/zone.lykos.stabilitymatrix.desktop" || die "Failed to install .desktop file"
  insinto /usr/share/icons
  doins -r "${WORKDIR}/squashfs-root/usr/share/icons/hicolor/" || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

