# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-lemmy-notify-appimage-update.yaml
EAPI=8
DESCRIPTION="Lemmy Notification app - for desktop atm"
HOMEPAGE=""
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
  amd64? ( https://github.com/arran4/lemmy_notify/releases/download/v0.0.4/lemmy_notify-linux-x86_64.AppImage -> ${P}-lemmy_notify-linux-x86_64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-lemmy_notify-linux-x86_64.AppImage" "lemmy_notify.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "lemmy_notify.AppImage"  || die "Can't chmod archive file"
  "./lemmy_notify.AppImage" --appimage-extract "lemmy_notify.desktop" || die "Failed to extract .desktop from appimage"
  "./lemmy_notify.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  "./lemmy_notify.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/lemmy_notify.AppImage:' 'squashfs-root/lemmy_notify.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "lemmy_notify.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/lemmy_notify.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

