# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-im-simplex-chat-appimage-update.yaml
EAPI=8
DESCRIPTION="SimpleX - the first messaging network operating without user identifiers of any kind - 100% private by design! iOS, Android and desktop apps 📱!"
HOMEPAGE="https://simplex.chat"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="
  amd64? ( https://github.com/simplex-chat/simplex-chat/releases/download/v6.4.0-beta.5/simplex-desktop-x86_64.AppImage -> ${P}-simplex-desktop-x86_64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-simplex-desktop-x86_64.AppImage" "simplex-desktop.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "simplex-desktop.AppImage"  || die "Can't chmod archive file"
  "./simplex-desktop.AppImage" --appimage-extract "chat.simplex.app.desktop" || die "Failed to extract .desktop from appimage"
  "./simplex-desktop.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/simplex-desktop.AppImage:' 'squashfs-root/chat.simplex.app.desktop'
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "simplex-desktop.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/chat.simplex.app.desktop" || die "Failed to install desktop file"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

