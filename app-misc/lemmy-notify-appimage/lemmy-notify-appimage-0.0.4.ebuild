# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/
EAPI=8
DESCRIPTION="Lemmy Notification app - for desktop atm"
HOMEPAGE="https://github.com/arran4/lemmy_notify"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="https://github.com/arran4/lemmy_notify/releases/download/${PV}/lemmy_notify-linux-x86_64.AppImage -> $P.AppImage"

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}" || die "Can't copy archive file"
  chmod a+x "${A}" || die "Can't chmod archive file"
  ./ --appimage-extract \*.desktop || die "Can't extract .desktop file from AppImage"
  ./ --appimage-extract usr/share/icons || die "Can't extract icons from AppImage"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/lemmy_notify.AppImage:' squashfs-root/*.desktop
  sed -i 's:^TryExec=.*:TryExec=/opt/bin/lemmy_notify.AppImage:' squashfs-root/*.desktop
  eapply_user
}

src_install() {
  mv "${WORKDIR}/${P}.AppImage" "${WORKDIR}/lemmy_notify.AppImage"
  exeinto /opt/bin
  doexe "${WORKDIR}/lemmy_notify.AppImage" || die "Failed to install AppImage"
  dosym /opt/bin/lemmy_notify.AppImage /usr/bin/lemmy-notify
  insinto /usr/share/applications
  doins "${WORKDIR}/squashfs-root/*.desktop" || die "Failed to install .desktop file"
  insinto /usr/share/icons/hicolor
  doins -r "${WORKDIR}/squashfs-root/usr/share/icons" || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

