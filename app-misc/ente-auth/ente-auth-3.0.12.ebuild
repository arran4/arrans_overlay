# Copyright
EAPI=8
DESCRIPTION="Ente Auth AppImage"
SRC_URI="https://github.com/ente-io/ente/releases/download/auth-v3.0.12/ente-auth-v3.0.12-x86_64.AppImage -> auth
        https://github.com/ente-io/ente/releases/download/auth-v3.0.12/ente-auth-v3.0.12-x86_64.deb -> auth.deb"
LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND="|| ( dev-libs/libappindicator )"
S="${WORKDIR}"

inherit unpacker
inherit xdg-utils

src_unpack() {
    unpack_deb auth.deb
}

src_install() {
    exeinto /usr/bin
    mv "${DISTDIR}/auth" 'ente_auth'
    doexe ente_auth
    insinto /usr/share/applications
    doins usr/share/applications/ente_auth.desktop
    insinto /usr/share/
    doins -r usr/share/icons
}

pkg_postinst() {
    xdg_desktop_database_update
}

