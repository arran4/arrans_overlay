# Copyright
EAPI=8
DESCRIPTION="Ente Auth AppImage"
SRC_URI="https://github.com/ente-io/ente/releases/download/auth-v3.0.17/ente-auth-v3.0.17-x86_64.AppImage -> ${P}"
LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND="|| ( dev-libs/libappindicator )"
S="${WORKDIR}"

inherit xdg-utils

src_unpack() {
    chmod a+x "${DISTDIR}/${A}" || die 'Can't find archive file'
    "${DISTDIR}/${A}" --appimage-extract ente_auth.desktop || die 'Can't extract .desktop from appimage'
    "${DISTDIR}/${A}" --appimage-extract usr/share/icons || die 'Can't extract icons from app image'
}

src_prepare() {
    sed -i 's:^Exec=.*:Exec=/opt/bin/ente_auth:' squashfs-root/ente_auth.desktop
    eapply_user
}

src_install() {
    exeinto /opt/bin
    mv "${DISTDIR}/${P}" "ente_auth"
    doexe ente_auth
    insinto /usr/share/applications
    doins "${DISTDIR}/squashfs-root/ente_auth.desktop"
    insinto /usr/share/
    doins -r "${DISTDIR}/squashfs-root/usr/share/icons"
}

pkg_postinst() {
    xdg_desktop_database_update
}

