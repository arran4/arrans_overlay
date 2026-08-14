# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-editors-zed-bin-update.yaml
EAPI=8
DESCRIPTION="A high-performance, multiplayer code editor from the creators of Atom and Tree-sitter"
HOMEPAGE="https://zed.dev"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/zed-industries/zed/releases/download/v0.194.3/zed-linux-x86_64.tar.gz -> ${P}-zed-linux-x86_64.tar.gz  )  
  arm64? (  https://github.com/zed-industries/zed/releases/download/v0.194.3/zed-linux-aarch64.tar.gz -> ${P}-zed-linux-aarch64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-zed-linux-x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-zed-linux-aarch64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "zed.app/bin/zed" "zed" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "zed.app/bin/zed" "zed" || die "Failed to install Binary"
  fi
}

