# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-im-caprine-appimage-update.yaml
EAPI=8
DESCRIPTION="Elegant Facebook Messenger desktop app"
HOMEPAGE="https://sindresorhus.com/caprine"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

SRC_URI="https://github.com/sindresorhus/caprine/releases/download/v${PV}/Caprine-${PV}.AppImage -> ${P}.amd64"

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}" || die "Can't copy archive file"
  chmod a+x "${A}" || die "Can't chmod archive file"
  "./${A}" --appimage-extract caprine.desktop || die "Failed to extract .desktop from appimage"
  "./${A}" --appimage-extract usr/share/icons || die "Failed to extract icons from app image"
}

src_prepare() {
  sed -i s:^Exec=.*:Exec=/opt/bin/caprine.AppImage: squashfs-root/caprine.desktop
  eapply_user
}

src_install() {
  mv "${P}.amd64" "caprine.AppImage" || die "Failed to rename AppImage"
  exeinto /opt/bin
  doexe "caprine.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins squashfs-root/caprine.desktop || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

