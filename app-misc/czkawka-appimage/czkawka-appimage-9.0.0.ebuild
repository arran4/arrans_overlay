# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-czkawka-appimage-update.yaml
EAPI=8
DESCRIPTION="Multi functional app to find duplicates, empty folders, similar images etc."
HOMEPAGE="https://github.com/qarmin/czkawka"
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
  amd64? ( https://github.com/qarmin/czkawka/releases/download/9.0.0/linux_czkawka_gui.AppImage -> ${P}-linux_czkawka_gui.AppImage )
  amd64? ( https://github.com/qarmin/czkawka/releases/download/9.0.0/linux_czkawka_gui_minimal.AppImage -> ${P}-linux_czkawka_gui_minimal.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-linux_czkawka_gui.AppImage" "czkawka_gui.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "czkawka_gui.AppImage"  || die "Can't chmod archive file"
  "./czkawka_gui.AppImage" --appimage-extract "com.github.qarmin.czkawka.desktop" || die "Failed to extract .desktop from appimage"
  "./czkawka_gui.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  "./czkawka_gui.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
  if use amd64; then
    cp "${DISTDIR}/${P}-linux_czkawka_gui_minimal.AppImage" "czkawka_gui_minimal.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "czkawka_gui_minimal.AppImage"  || die "Can't chmod archive file"
  "./czkawka_gui_minimal.AppImage" --appimage-extract "com.github.qarmin.czkawka.desktop" || die "Failed to extract .desktop from appimage"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/czkawka_gui.AppImage:' 'squashfs-root/com.github.qarmin.czkawka.desktop'
  sed -i 's:^Exec=.*:Exec=/opt/bin/czkawka_gui_minimal.AppImage:' 'squashfs-root/com.github.qarmin.czkawka.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "czkawka_gui.AppImage" || die "Failed to install AppImage"
  doexe "czkawka_gui_minimal.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/com.github.qarmin.czkawka.desktop" || die "Failed to install desktop file"
  doins "squashfs-root/com.github.qarmin.czkawka.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

