# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-go-appimage-appimage-update.yaml
EAPI=8
DESCRIPTION=" Go implementation of AppImage tools "
HOMEPAGE="https://github.com/probonopd/go-appimage"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="  
  arm64? ( https://github.com/probonopd/go-appimage/releases/download/continuous/appimaged-855-aarch64.AppImage -> $P.appimaged.arm64 )
  arm? ( https://github.com/probonopd/go-appimage/releases/download/continuous/appimaged-855-armhf.AppImage -> $P.appimaged.arm )
  x86? ( https://github.com/probonopd/go-appimage/releases/download/continuous/appimaged-855-i686.AppImage -> $P.appimaged.x86 )
  amd64? ( https://github.com/probonopd/go-appimage/releases/download/continuous/appimaged-855-x86_64.AppImage  -> $P.appimaged.amd64 )
  arm64? ( https://github.com/probonopd/go-appimage/releases/download/continuous/appimagetool-855-aarch64.AppImage -> $P.appimagetool.arm64 )
  arm? ( https://github.com/probonopd/go-appimage/releases/download/continuous/appimagetool-855-armhf.AppImage -> $P.appimagetool.arm )
  x86? ( https://github.com/probonopd/go-appimage/releases/download/continuous/appimagetool-855-i686.AppImage -> $P.appimagetool.x86 )
  amd64? ( https://github.com/probonopd/go-appimage/releases/download/continuous/appimagetool-855-x86_64.AppImage  -> $P.appimagetool.amd64 )
  arm64? ( https://github.com/probonopd/go-appimage/releases/download/continuous/mkappimage-855-aarch64.AppImage -> $P.mkappimage.arm64 )
  arm? ( https://github.com/probonopd/go-appimage/releases/download/continuous/mkappimage-855-armhf.AppImage -> $P.mkappimage.arm )
  x86? ( https://github.com/probonopd/go-appimage/releases/download/continuous/mkappimage-855-i686.AppImage -> $P.mkappimage.x86 )
  amd64? ( https://github.com/probonopd/go-appimage/releases/download/continuous/mkappimage-855-x86_64.AppImage  -> $P.mkappimage.amd64 )
" 

src_unpack() {
  for oe in ${A}; do
    e="$(echo "${oe#$P}" | cut -d. -f 2)"
    echo "$oe: ${oe#$P}: $e"
    efn="${e}.AppImage"
    cp "${DISTDIR}/${oe}" "${efn}"  || die "Can't copy ${e}"
    chmod a+x "${efn}"  || die "Can't chmod ${e} file"
  done
}

src_prepare() {
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe "appimaged.AppImage"
  doexe "appimagetool.AppImage"
  doexe "mkappimage.AppImage"
}

