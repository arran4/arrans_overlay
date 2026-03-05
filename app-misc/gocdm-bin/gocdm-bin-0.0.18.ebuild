# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-gocdm-bin-update.yaml
EAPI=8
DESCRIPTION="The Console Display Manager (Go Port)"
HOMEPAGE="https://github.com/arran4/gocdm"
SRC_URI="
  amd64? (  https://github.com/arran4/gocdm/releases/download/v${PV}/gocdm_Linux_x86_64.tar.gz -> ${P}-gocdm_Linux_x86_64.tar.gz  )  
  arm64? (  https://github.com/arran4/gocdm/releases/download/v${PV}/gocdm_Linux_arm64.tar.gz -> ${P}-gocdm_Linux_arm64.tar.gz  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-gocdm_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-gocdm_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "gocdm" "gocdm" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "gocdm" "gocdm" || die "Failed to install Binary"
  fi
}
