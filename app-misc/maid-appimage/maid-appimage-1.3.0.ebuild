# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-maid-appimage-update.yaml
EAPI=8
DESCRIPTION="Maid is a cross-platform Flutter app for interfacing with GGUF / llama.cpp models locally, and with Ollama and OpenAI models remotely."
HOMEPAGE=""
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
  amd64? ( https://github.com/Mobile-Artificial-Intelligence/maid/releases/download/1.3.0/maid.AppImage -> ${P}-maid.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-maid.AppImage" "maid.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "maid.AppImage"  || die "Can't chmod archive file"
  ./maid.AppImage --appimage-extract "maid.desktop" || die "Failed to extract .desktop from appimage"
  ./maid.AppImage --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/maid.AppImage:' 'squashfs-root/maid.desktop'
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "maid.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/maid.desktop" || die "Failed to install desktop file"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

