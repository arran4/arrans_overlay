# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-appimagetool-appimage-update.yaml
EAPI=8
DESCRIPTION="AppImage tool to create AppImages (As an AppImage)"
HOMEPAGE="https://github.com/AppImage/AppImageKit"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="  
  amd64? ( https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -> $P.amd64 )
  x86? ( https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-i686.AppImage -> $P.x86 )
  arm? ( https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-armhf.AppImage -> $P.arm )
  arm64? ( https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-aarch64.AppImage -> $P.arm64 )
" 

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}"  || die "Can't copy archive file"
  chmod a+x "${A}"  || die "Can't chmod archive file"
  "./${A}" --appimage-extract appimagetool.desktop  || die "Can't extract .desktop from appimage"
  "./${A}" --appimage-extract usr/share/icons  || die "Can't extract icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/appimagetool:' squashfs-root/appimagetool.desktop
  find squashfs-root -type d -exec rmdir -p {} \; 
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm -v {} \; 
  eapply_user
}

src_install() {
  mv -v "./${A}" appimagetool
  exeinto /opt/bin
  doexe "appimagetool"
  insinto /usr/share/applications
  doins "./squashfs-root/appimagetool.desktop"
  insinto /usr/share/
  doins -r "./squashfs-root/usr/share/icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

