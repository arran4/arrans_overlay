# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-im-hex-appimage-update.yaml
EAPI=8
DESCRIPTION="🔍 A Hex Editor for Reverse Engineers, Programmers and people who value their retinas when working at 3 AM."
HOMEPAGE="https://imhex.werwolv.net"
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
  amd64? ( https://github.com/WerWolv/ImHex/releases/download/v1.37.4/imhex-${PV}-x86_64.AppImage -> ${P}-imhex-${PV}-x86_64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-imhex-${PV}-x86_64.AppImage" "ImHex.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "ImHex.AppImage"  || die "Can't chmod archive file"
  "./ImHex.AppImage" --appimage-extract "imhex.desktop" || die "Failed to extract .desktop from appimage"
  "./ImHex.AppImage" --appimage-extract "usr/share/pixmaps" || die "Failed to extract pixmaps icons from app image"
  "./ImHex.AppImage" --appimage-extract "*.svg" || die "Failed to extract root icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/ImHex.AppImage:' 'squashfs-root/imhex.desktop'
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "ImHex.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/imhex.desktop" || die "Failed to install desktop file"
  insinto /usr/share/pixmaps
  doins squashfs-root/usr/share/pixmaps/*.svg || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.svg || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

