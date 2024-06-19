# appimagetool ebuild file
EAPI=8
DESCRIPTION="AppImage tool to create AppImages (As an AppImage)"
HOMEPAGE="https://github.com/AppImage/AppImageKit"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
SRC_URI="  
  amd64? ( https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -> $P.amd64 )
  x86? ( https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-i686.AppImage -> $P.x86 )
  arm? ( https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-armhf.AppImage -> $P.arm )
  arm64? ( https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-aarch64.AppImage -> $P.arm64 )
" 
src_unpack() {
  true
}
src_install() {
  mv -v "${DISTDIR}/${A}" appimagetool
  exeinto /usr/bin
  doexe "appimagetool"
}
