# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-gdu-bin-update.yaml
EAPI=8
DESCRIPTION="Fast disk usage analyzer with console interface written in Go"
HOMEPAGE="https://github.com/dundee/gdu"
SRC_URI="
  amd64? (  https://github.com/dundee/gdu/releases/download/v${PV}/gdu_linux_amd64.tgz -> ${P}-gdu_linux_amd64.tgz  )  
  arm? (  https://github.com/dundee/gdu/releases/download/v${PV}/gdu_linux_armv7l.tgz -> ${P}-gdu_linux_armv7l.tgz  )  
  arm64? (  https://github.com/dundee/gdu/releases/download/v${PV}/gdu_linux_arm64.tgz -> ${P}-gdu_linux_arm64.tgz  )  
  x86? (  https://github.com/dundee/gdu/releases/download/v${PV}/gdu_linux_386.tgz -> ${P}-gdu_linux_386.tgz  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-gdu_linux_amd64.tgz" || die "Can't unpack archive file"
    mv "${WORKDIR}/gdu_linux_amd64" "${S}/gdu" || die
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-gdu_linux_armv7l.tgz" || die "Can't unpack archive file"
    mv "${WORKDIR}/gdu_linux_armv7l" "${S}/gdu" || die
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-gdu_linux_arm64.tgz" || die "Can't unpack archive file"
    mv "${WORKDIR}/gdu_linux_arm64" "${S}/gdu" || die
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-gdu_linux_386.tgz" || die "Can't unpack archive file"
    mv "${WORKDIR}/gdu_linux_386" "${S}/gdu" || die
  fi
}

src_install() {
  dobin gdu
}
