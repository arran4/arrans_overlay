# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-im-caprine-appimage-update.yaml
EAPI=8
DESCRIPTION="Elegant Facebook Messenger desktop app"
HOMEPAGE="https://sindresorhus.com/caprine"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

SRC_URI="https://github.com/sindresorhus/caprine/releases/download/v${PV}/Caprine-${PV}.AppImage -> ${P}.AppImage"

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}" || die "Can't copy archive file"
  chmod a+x "${A}" || die "Can't chmod archive file"
  "./${A}" --appimage-extract caprine.desktop || die "Can't extract .desktop from appimage"
  "./${A}" --appimage-extract usr/share/icons || die "Can't extract icons from app image"
}

src_prepare() {
  sed -i s:^Exec=.*:Exec=/opt/bin/caprine: squashfs-root/caprine.desktop
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe squashfs-root/AppRun || die "Failed to install AppRun"
  insinto /usr/share/applications
  doins squashfs-root/caprine.desktop
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/*
}

pkg_postinst() {
  xdg_desktop_database_update
}

