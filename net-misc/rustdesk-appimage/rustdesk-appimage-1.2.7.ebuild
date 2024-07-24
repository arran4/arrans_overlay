# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-misc-rustdesk-appimage-update.yaml
EAPI=8
DESCRIPTION="An open-source remote desktop, and alternative to TeamViewer."
HOMEPAGE="https://github.com/rustdesk/rustdesk"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="  
  amd64? ( https://github.com/rustdesk/rustdesk/releases/download/${PV}/rustdesk-${PV}-x86_64.AppImage -> $P.amd64 )
  arm64? ( https://github.com/rustdesk/rustdesk/releases/download/${PV}/rustdesk-${PV}-aarch64.AppImage -> $P.arm64 )
" 

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}"  || die "Can't copy archive file"
  chmod a+x "${A}"  || die "Can't chmod archive file"
  "./${A}" --appimage-extract rustdesk.desktop || die "Can't extract .desktop from appimage"
  "./${A}" --appimage-extract usr/share/icons || die "Can't extract icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/rustdesk:' squashfs-root/rustdesk.desktop
  find squashfs-root -type d -exec rmdir -p {} \; 
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  eapply_user
}

src_install() {
  mv -v "${DISTDIR}/${A}" rustdesk
  exeinto /opt/bin
  doexe "rustdesk"
  insinto /usr/share/applications
  doins "./squashfs-root/rustdesk.desktop"
  insinto /usr/share/
  doins -r "./squashfs-root/usr/share/icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

