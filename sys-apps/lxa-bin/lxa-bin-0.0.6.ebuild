# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/sys-apps-lxa-bin-update.yaml
EAPI=8
DESCRIPTION="A Linux-first file listing and inspection tool focused on extended attributes"
HOMEPAGE="https://github.com/arran4/lxa"
SRC_URI="
  amd64? (  https://github.com/arran4/lxa/releases/download/v${PV}/lxa_${PV}_linux_amd64.tar.gz -> ${P}-lxa_${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/arran4/lxa/releases/download/v${PV}/lxa_${PV}_linux_arm64.tar.gz -> ${P}-lxa_${PV}_linux_arm64.tar.gz  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-lxa_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-lxa_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /usr/bin
  if use amd64; then
    newexe "lxa" "lxa" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "lxa" "lxa" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "README.md" "README.md" || die "Failed to install document README.md"
  fi
}
