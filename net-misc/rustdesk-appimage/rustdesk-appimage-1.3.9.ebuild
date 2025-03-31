# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-misc-rustdesk-appimage-update.yaml
EAPI=8
DESCRIPTION="An open-source remote desktop application designed for self-hosting, as an alternative to TeamViewer."
HOMEPAGE="https://rustdesk.com"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
DEPEND=""
RDEPEND="sys-libs/glibc sys-libs/glibc sys-libs/zlib sys-libs/zlib "
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="
  arm64? ( https://github.com/rustdesk/rustdesk/releases/download/1.3.9/rustdesk-1.3.9-aarch64.AppImage -> ${P}-rustdesk-1.3.9-aarch64.AppImage )
  amd64? ( https://github.com/rustdesk/rustdesk/releases/download/1.3.9/rustdesk-1.3.9-x86_64.AppImage -> ${P}-rustdesk-1.3.9-x86_64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-rustdesk-1.3.9-x86_64.AppImage" "rustdesk.AppImage"  || die "Can't copy downloaded file"
  fi
  if use arm64; then
    cp "${DISTDIR}/${P}-rustdesk-1.3.9-aarch64.AppImage" "rustdesk.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "rustdesk.AppImage"  || die "Can't chmod archive file"
  "./rustdesk.AppImage" --appimage-extract "rustdesk.desktop" || die "Failed to extract .desktop from appimage"
  "./rustdesk.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/rustdesk.AppImage:' 'squashfs-root/rustdesk.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "rustdesk.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/rustdesk.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

