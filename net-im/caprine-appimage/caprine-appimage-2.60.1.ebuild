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

SRC_URI="https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}/releases/download/v${PV}/Caprine-${PV}.AppImage -> ${P}.AppImage"

src_unpack() {
  cp "${DISTDIR}/${A}" "${A}" || die "Cant copy archive file'
      echo '  chmod a+x  || die Cant chmod archive file"
  "./${A}" --appimage-extract ${DESKTOP_FILE} || die "Cant extract .desktop from appimage'
      echo '  ./ --appimage-extract usr/share/icons || die Cant extract icons from app image"
}

src_prepare() {
  sed -i s:^Exec=.*:Exec=/opt/bin/caprine: squashfs-root/${DESKTOP_FILE}
  eapply_user
}

src_install() {
  exeinto /opt/bin
  doexe squashfs-root/AppRun || die "Failed to install AppRun"
  insinto /usr/share/applications
  doins squashfs-root/${DESKTOP_FILE}
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/*
}

pkg_postinst() {
  xdg_desktop_database_update
}

