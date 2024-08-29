# Copyright
EAPI=8
DESCRIPTION="Ente Auth AppImage"
HOMEPAGE="https://ente.io/blog/auth/"
SRC_URI="https://github.com/ente-io/ente/releases/download/auth-v3.0.17/ente-auth-v3.0.17-x86_64.AppImage -> ${P}"
LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND="|| ( dev-libs/libindicator )"
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}"  || die "Can't copy archive file"
  chmod a+x "${A}"  || die "Can't chmod archive file"
  "./${A}" --appimage-extract ente_auth.desktop || die "Can't extract .desktop from appimage"
  "./${A}" --appimage-extract usr/share/icons || die "Can't extract icons from app image"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/ente_auth:' squashfs-root/ente_auth.desktop
  eapply_user
}

src_install() {
  exeinto /opt/bin
  mv "./${A}" "ente_auth"
  doexe ente_auth
  insinto /usr/share/applications
  doins "./squashfs-root/ente_auth.desktop"
  insinto /usr/share/
  doins -r "./squashfs-root/usr/share/icons"
}

pkg_postinst() {
    xdg_desktop_database_update
}

