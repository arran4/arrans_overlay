# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-flutter-google-datastore-appimage-update.yaml
EAPI=8
DESCRIPTION="Google Datastore and Datastore emulator client for easy modification of values"
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
  amd64? ( https://github.com/arran4/flutter_google_datastore/releases/download/v0.1.26/flutter_google_datastore-0.1.26-linux.AppImage -> ${P}-flutter_google_datastore-0.1.26-linux.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-flutter_google_datastore-0.1.26-linux.AppImage" "FlutterGoogleDatastore.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "FlutterGoogleDatastore.AppImage"  || die "Can't chmod archive file"
  "./FlutterGoogleDatastore.AppImage" --appimage-extract "flutter_google_datastore.desktop" || die "Failed to extract .desktop from appimage"
  "./FlutterGoogleDatastore.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  "./FlutterGoogleDatastore.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/FlutterGoogleDatastore.AppImage:' 'squashfs-root/flutter_google_datastore.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "FlutterGoogleDatastore.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/flutter_google_datastore.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

