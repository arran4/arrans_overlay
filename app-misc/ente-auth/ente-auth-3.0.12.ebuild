# Copyright 

EAPI=8
DESCRIPTION="Ente Auth AppImage"
SRC_URI="https://github.com/ente-io/ente/releases/download/auth-v${PV}/ente-auth-v${PV}-x86_64.AppImage -> auth"
LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"

src_unpack() {
        true
}

src_install() {
        exeinto /usr/bin
        doexe auth
}
