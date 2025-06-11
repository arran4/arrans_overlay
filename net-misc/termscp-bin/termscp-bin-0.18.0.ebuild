# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-misc-termscp-bin-update.yaml
EAPI=8
DESCRIPTION="Feature rich terminal file transfer tool"
HOMEPAGE="https://termscp.veeso.dev"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND="net-fs/samba sys-libs/glibc "
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/veeso/termscp/releases/download/v0.18.0/termscp-v${PV}-x86_64-unknown-linux-gnu.tar.gz -> ${P}-termscp-v${PV}-x86_64-unknown-linux-gnu.tar.gz  )  
  arm64? (  https://github.com/veeso/termscp/releases/download/v0.18.0/termscp-${PV}-aarch64-unknown-linux-gnu.tar.gz -> ${P}-termscp-${PV}-aarch64-unknown-linux-gnu.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-termscp-v${PV}-x86_64-unknown-linux-gnu.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-termscp-${PV}-aarch64-unknown-linux-gnu.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "termscp" "termscp" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "termscp" "termscp" || die "Failed to install Binary"
  fi
}

