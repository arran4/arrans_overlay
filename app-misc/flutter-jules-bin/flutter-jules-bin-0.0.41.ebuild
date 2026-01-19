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

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-flutter_jules-linux.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "flutter_jules/flutter_jules" "jules_client" || die "Failed to install Binary"
  fi
}
