# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-jan-appimage-update.yaml
EAPI=8
DESCRIPTION="Jan is an open source alternative to ChatGPT that runs 100% offline on your computer. Multiple engine support (llama.cpp, TensorRT-LLM)"
HOMEPAGE="https://jan.ai/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

SRC_URI="https://github.com//janhq/jan/releases/download/v${PV}/jan-linux-x86_64-${PV}.AppImage -> ${P}.AppImage"

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}"  || die "Can't copy archive file"
  chmod a+x "${A}"  || die "Can't chmod archive file"
  ./${A} --appimage-extract jan.desktop || die "Can't extract .desktop from appimage"
  ./${A} --appimage-extract usr/share/icons || die "Can't extract icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/jan:' squashfs-root/jan.desktop
  eapply_user
}

src_install() {
  mv "${P}.amd64" "jan"
  exeinto /opt/bin
  doexe "jan" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins squashfs-root/jan.desktop
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor
}

