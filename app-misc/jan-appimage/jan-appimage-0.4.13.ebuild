# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-jan-appimage-update.yaml
EAPI=8
DESCRIPTION="Jan is an open source alternative to ChatGPT that runs 100% offline on your computer. Multiple engine support (llama.cpp, TensorRT-LLM)"
HOMEPAGE="https://jan.ai/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="https://github.com//janhq/jan/releases/download/v${PV}/jan-linux-x86_64-${PV}.AppImage -> ${P}.amd64"

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}"  || die "Can't copy archive file"
  chmod a+x "${A}"  || die "Can't chmod archive file"
  ./${A} --appimage-extract jan.desktop || die "Failed to extract .desktop from appimage"
  ./${A} --appimage-extract usr/share/icons || die "Failed to extract icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/jan.AppImage:' squashfs-root/jan.desktop
  eapply_user
}

src_install() {
  mv "${P}.amd64" "jan.AppImage" || die "Failed to rename AppImage"
  exeinto /opt/bin
  doexe "jan.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins squashfs-root/jan.desktop || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

