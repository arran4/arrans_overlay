# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-layerx-bin-update.yaml
EAPI=8
DESCRIPTION="Interactive Docker image layer inspector"
HOMEPAGE="https://github.com/deveshctl/layerx"
SRC_URI="
  amd64? (  https://github.com/deveshctl/layerx/releases/download/v${PV}/layerx_linux_amd64.tar.gz -> ${P}-layerx_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/deveshctl/layerx/releases/download/v${PV}/layerx_linux_arm64.tar.gz -> ${P}-layerx_linux_arm64.tar.gz  )  
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
    unpack "${DISTDIR}/${P}-layerx_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-layerx_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "layerx" "layerx" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "layerx" "layerx" || die "Failed to install Binary"
  fi
}
