# rustdesk ebuild file
EAPI=8
DESCRIPTION="An open-source remote desktop, and alternative to TeamViewer."
HOMEPAGE="https://github.com/rustdesk/rustdesk"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"

SRC_URI="  
  amd64? ( https://github.com/rustdesk/rustdesk/releases/download/${release}/rustdesk-${PV}-x86_64.AppImage -> $P.amd64 )
  arm64? ( https://github.com/rustdesk/rustdesk/releases/download/${release}/rustdesk-${PV}-aarch64.AppImage -> $P.arm64 )
" 

src_unpack() {
    chmod a+x ${A}
    ./${A} --appimage-extract rustdesk.desktop
    ./${A} --appimage-extract usr/share/icons
}

src_prepare() {
    sed -i 's:^Exec=.*:Exec=/opt/bin/rustdesk:' squashfs-root/rustdesk.desktop
    eapply_user
}

src_install() {
    mv -v "${DISTDIR}/${A}" rustdesk
    exeinto /opt/bin
    doexe "rustdesk"
    insinto /usr/share/applications
    doins "${DISTDIR}/squashfs-root/rustdesk.desktop"
    insinto /usr/share/
    doins -r "${DISTDIR}/squashfs-root/usr/share/icons"
}

pkg_postinst() {
    xdg_desktop_database_update
}

