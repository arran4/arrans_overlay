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
    chmod a+x ${A}
    ./${A} --appimage-extract appimagetool.desktop
    ./${A} --appimage-extract usr/share/icons
}

src_prepare() {
    sed -i 's:^Exec=.*:Exec=/opt/bin/appimagetool:' squashfs-root/appimagetool.desktop
    eapply_user
}

src_install() {
    mv -v "${DISTDIR}/${A}" appimagetool
    exeinto /opt/bin
    doexe "appimagetool"
    insinto /usr/share/applications
    doins "${DISTDIR}/squashfs-root/appimagetool.desktop"
    insinto /usr/share/
    doins -r "${DISTDIR}/squashfs-root/usr/share/icons"
}

pkg_postinst() {
    xdg_desktop_database_update
}

