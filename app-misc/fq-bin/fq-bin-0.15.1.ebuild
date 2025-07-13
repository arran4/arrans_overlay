# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-fq-bin-update.yaml
EAPI=8
DESCRIPTION="jq for binary formats - tool, language and decoders for working with binary and text formats"
HOMEPAGE="https://github.com/wader/fq"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/wader/fq/releases/download/v0.15.1/fq_${PV}_linux_amd64.tar.gz -> ${P}-fq_${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/wader/fq/releases/download/v0.15.1/fq_${PV}_linux_arm64.tar.gz -> ${P}-fq_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-fq_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-fq_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "fq" "fq" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "fq" "fq" || die "Failed to install Binary"
  fi
}

