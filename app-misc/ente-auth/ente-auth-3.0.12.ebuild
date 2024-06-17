# Copyright
 EAPI=8
 DESCRIPTION="Ente Auth AppImage"
 SRC_URI="https://github.com/ente-io/ente/releases/download/auth-v3.0.12/ente-auth-v3.0.12-x86_64.AppImage -> auth"
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

