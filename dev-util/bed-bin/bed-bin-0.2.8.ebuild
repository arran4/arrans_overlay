# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-bed-bin-update.yaml
EAPI=8
DESCRIPTION="Binary editor written in Go."
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
  amd64? (  https://github.com/itchyny/bed/releases/download/v0.2.8/bed_v${PV}_linux_amd64.tar.gz -> ${P}-bed_v${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/itchyny/bed/releases/download/v0.2.8/bed_v${PV}_linux_arm64.tar.gz -> ${P}-bed_v${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-bed_v${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-bed_v${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "bed" "bed" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "bed" "bed" || die "Failed to install Binary"
  fi
}

