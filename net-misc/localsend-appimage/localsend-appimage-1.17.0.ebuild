# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-misc-localsend-appimage-update.yaml
EAPI=8
DESCRIPTION="An open-source cross-platform alternative to AirDrop"
HOMEPAGE="https://localsend.org"
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
  amd64? ( https://github.com/localsend/localsend/releases/download/v1.17.0/LocalSend-${PV}-linux-x86-64.AppImage -> ${P}-LocalSend-${PV}-linux-x86-64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-LocalSend-${PV}-linux-x86-64.AppImage" "localsend.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "localsend.AppImage"  || die "Can't chmod archive file"
  "./localsend.AppImage" --appimage-extract "org.localsend.localsend_app.desktop" || die "Failed to extract .desktop from appimage"
  "./localsend.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  "./localsend.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/localsend.AppImage:' 'squashfs-root/org.localsend.localsend_app.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "localsend.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/org.localsend.localsend_app.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

