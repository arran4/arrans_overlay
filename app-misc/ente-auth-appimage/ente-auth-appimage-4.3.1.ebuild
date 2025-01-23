# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-ente-auth-appimage-update.yaml
EAPI=8
DESCRIPTION="Ente's 2FA solution"
HOMEPAGE="https://ente.io/blog/auth/"
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
  amd64? ( https://github.com/ente-io/ente/releases/download/auth-v4.3.1/ente-auth-v4.3.1-x86_64.AppImage -> ${P}-ente-auth-v4.3.1-x86_64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-ente-auth-v4.3.1-x86_64.AppImage" "ente_auth.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "ente_auth.AppImage"  || die "Can't chmod archive file"
  "./ente_auth.AppImage" --appimage-extract "enteauth.desktop" || die "Failed to extract .desktop from appimage"
  "./ente_auth.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  "./ente_auth.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/ente_auth.AppImage:' 'squashfs-root/enteauth.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "ente_auth.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/enteauth.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

