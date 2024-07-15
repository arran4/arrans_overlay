# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-local-ai-appimage-update.yaml
EAPI=8
DESCRIPTION="🎒 local.ai - Run AI locally on your PC!"
HOMEPAGE="https://localai.app"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="
  amd64? ( https://github.com/louisgv/local.ai/releases/download/v0.6.6/local-ai_${PV}_amd64.AppImage -> ${P}-local-ai_${PV}_amd64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-local-ai_${PV}_amd64.AppImage" "local-ai.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "local-ai.AppImage"  || die "Can't chmod archive file"
  ./local-ai.AppImage --appimage-extract "local-ai.desktop" || die "Failed to extract .desktop from appimage"
  ./local-ai.AppImage --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  ./local-ai.AppImage --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/local-ai.AppImage:' 'squashfs-root/local-ai.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "local-ai.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/local-ai.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

