# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-flutter-jules-bin-update.yaml
EAPI=8
DESCRIPTION="A comprehensive Flutter-based client application for interacting with the Google Jules API."
HOMEPAGE="https://github.com/arran4/flutter_jules"
SRC_URI="
	amd64? (  https://github.com/arran4/flutter_jules/releases/download/v${PV}/flutter_jules-linux.tar.gz -> ${P}-flutter_jules-linux.tar.gz  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

REQUIRED_USE=""

RDEPEND="media-libs/libglvnd sys-devel/gcc sys-libs/zlib x11-libs/gtk+ x11-libs/libX11 "

S="${WORKDIR}"

inherit xdg-utils

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-flutter_jules-linux.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "flutter_jules/flutter_jules" "flutter_jules" || die "Failed to install Binary"
    insinto /usr/share/applications
    doins "flutter_jules/share/applications/com.arran4.flutter_jules.desktop" || die "Failed to install desktop file"
    insinto /usr/share/icons
    doins -r "flutter_jules/share/icons/hicolor" || die "Failed to install icons"
  fi
}

pkg_postinst() {
  xdg_desktop_database_update
}

pkg_postrm() {
  xdg_desktop_database_update
}
