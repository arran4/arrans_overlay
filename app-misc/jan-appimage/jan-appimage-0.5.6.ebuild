# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-jan-appimage-update.yaml
EAPI=8
DESCRIPTION="Jan is an open source alternative to ChatGPT that runs 100% offline on your computer. Multiple engine support (llama.cpp, TensorRT-LLM)"
HOMEPAGE="https://jan.ai/"
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
  amd64? ( https://github.com/janhq/jan/releases/download/v0.5.6/jan-linux-x86_64-${PV}.AppImage -> ${P}-jan-linux-x86_64-${PV}.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-jan-linux-x86_64-${PV}.AppImage" "jan.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "jan.AppImage"  || die "Can't chmod archive file"
  "./jan.AppImage" --appimage-extract "jan.desktop" || die "Failed to extract .desktop from appimage"
  "./jan.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/jan.AppImage:' 'squashfs-root/jan.desktop'
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "jan.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/jan.desktop" || die "Failed to install desktop file"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

