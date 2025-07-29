# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-backhub-bin-update.yaml
EAPI=8
DESCRIPTION="Backhub helps maintain backups of multiple GitHub repos."
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
  amd64? (  https://github.com/Tanq16/backhub/releases/download/v0.7.0/backhub-linux-amd64.zip -> ${P}-backhub-linux-amd64.zip  )  
  arm64? (  https://github.com/Tanq16/backhub/releases/download/v0.7.0/backhub-linux-arm64.zip -> ${P}-backhub-linux-arm64.zip  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-backhub-linux-amd64.zip" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-backhub-linux-arm64.zip" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "backhub" "backhub" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "backhub" "backhub" || die "Failed to install Binary"
  fi
}

