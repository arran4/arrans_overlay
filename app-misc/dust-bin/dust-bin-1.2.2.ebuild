# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-dust-bin-update.yaml
EAPI=8
DESCRIPTION="A more intuitive version of du written in Rust."
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
  amd64? (  https://github.com/bootandy/dust/releases/download/v1.2.2/dust-v${PV}-x86_64-unknown-linux-gnu.tar.gz -> ${P}-dust-v${PV}-x86_64-unknown-linux-gnu.tar.gz  )  
  arm64? (  https://github.com/bootandy/dust/releases/download/v1.2.2/dust-v${PV}-aarch64-unknown-linux-gnu.tar.gz -> ${P}-dust-v${PV}-aarch64-unknown-linux-gnu.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-dust-v${PV}-x86_64-unknown-linux-gnu.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-dust-v${PV}-aarch64-unknown-linux-gnu.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "dust" "dust" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "dust" "dust" || die "Failed to install Binary"
  fi
}

