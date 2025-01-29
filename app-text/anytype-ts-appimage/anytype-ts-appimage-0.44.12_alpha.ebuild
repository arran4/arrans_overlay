# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-text-anytype-ts-appimage-update.yaml
EAPI=8
DESCRIPTION="Official Anytype client for MacOS, Linux, and Windows"
HOMEPAGE="https://anytype.io"
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
  amd64? ( https://github.com/anyproto/anytype-ts/releases/download/v0.44.12-alpha/Anytype-0.44.12-alpha.AppImage -> ${P}-Anytype-${PV}.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-Anytype-${PV}.AppImage" "Anytype.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "Anytype.AppImage"  || die "Can't chmod archive file"
  "./Anytype.AppImage" --appimage-extract "anytype.desktop" || die "Failed to extract .desktop from appimage"
  "./Anytype.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  "./Anytype.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/Anytype.AppImage:' 'squashfs-root/anytype.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "Anytype.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/anytype.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

