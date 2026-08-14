# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-gdu-bin-update.yaml
EAPI=8
DESCRIPTION="Fast disk usage analyzer with console interface."
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/dundee/gdu/releases/download/v5.31.0/gdu_linux_amd64.tgz -> ${P}-gdu_linux_amd64.tgz  )  
  arm64? (  https://github.com/dundee/gdu/releases/download/v5.31.0/gdu_linux_arm64.tgz -> ${P}-gdu_linux_arm64.tgz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-gdu_linux_amd64.tgz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-gdu_linux_arm64.tgz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "gdu" "gdu" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "gdu" "gdu" || die "Failed to install Binary"
  fi
}

