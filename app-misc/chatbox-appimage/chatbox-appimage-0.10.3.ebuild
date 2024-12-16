# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-chatbox-appimage-update.yaml
EAPI=8
DESCRIPTION="User-friendly Desktop Client App for AI Models/LLMs (GPT, Claude, Gemini, Ollama...)"
HOMEPAGE="https://chatboxai.app"
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
  arm64? ( https://github.com/Bin-Huang/chatbox/releases/download/v0.10.3/Chatbox.CE-${PV}-arm64.AppImage -> ${P}-Chatbox-${PV}-arm64.AppImage )
  amd64? ( https://github.com/Bin-Huang/chatbox/releases/download/v0.10.3/Chatbox.CE-${PV}-x86_64.AppImage -> ${P}-Chatbox-${PV}-x86_64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-Chatbox.CE-${PV}-x86_64.AppImage" "chatbox.AppImage"  || die "Can't copy downloaded file"
  fi
  if use arm64; then
    cp "${DISTDIR}/${P}-Chatbox.CE-${PV}-arm64.AppImage" "chatbox.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "chatbox.AppImage"  || die "Can't chmod archive file"
  "./chatbox.AppImage" --appimage-extract "xyz.chatboxapp.app.desktop" || die "Failed to extract .desktop from appimage"
  "./chatbox.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
  "./chatbox.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/chatbox.AppImage:' 'squashfs-root/xyz.chatboxapp.app.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "chatbox.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/xyz.chatboxapp.app.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

