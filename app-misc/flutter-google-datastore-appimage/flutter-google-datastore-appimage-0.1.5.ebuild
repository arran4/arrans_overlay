# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/
EAPI=8
DESCRIPTION="Google Datastore and Datastore emulator client for easy modification of values"
HOMEPAGE="https://github.com/arran4/flutter_google_datastore"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="  
  amd64? ( https://github.com/arran4/flutter_google_datastore/releases/download/v${PV}/flutter_google_datastore-linux-x86_64.AppImage -> $P.amd64 )
" 

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}" || die "Can't copy archive file"
  chmod a+x "${A}" || die "Can't chmod archive file"
  ./${A} --appimage-extract \*.desktop || die "Can't extract .desktop file from AppImage"
  ./${A} --appimage-extract usr/share/icons || die "Can't extract icons from AppImage"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/FlutterGoogleDatastore.AppImage:' squashfs-root/*.desktop
  sed -i 's:^TryExec=.*:TryExec=/opt/bin/FlutterGoogleDatastore.AppImage:' squashfs-root/*.desktop
  eapply_user
}

src_install() {
  mv "${WORKDIR}/${P}.amd64" "${WORKDIR}/FlutterGoogleDatastore.AppImage"
  exeinto /opt/bin
  doexe "${WORKDIR}/FlutterGoogleDatastore.AppImage" || die "Failed to install AppImage"
  dosym /opt/bin/FlutterGoogleDatastore.AppImage /usr/bin/FlutterGoogleDatastore
  insinto /usr/share/applications
  doins "${WORKDIR}/squashfs-root/*.desktop" || die "Failed to install .desktop file"
  insinto /usr/share/icons
  doins -r "${WORKDIR}/squashfs-root/usr/share/icons/hicolor" || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

