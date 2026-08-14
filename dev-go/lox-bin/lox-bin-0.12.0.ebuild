# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-go-lox-bin-update.yaml
EAPI=8
DESCRIPTION="Lox lexer and parser generator for Go"
HOMEPAGE="https://dcaiafa.github.io/lox/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/dcaiafa/lox/releases/download/v0.12.0/lox_Linux_x86_64.tar.gz -> ${P}-lox_Linux_x86_64.tar.gz  )  
  arm64? (  https://github.com/dcaiafa/lox/releases/download/v0.12.0/lox_Linux_arm64.tar.gz -> ${P}-lox_Linux_arm64.tar.gz  )  
  x86? (  https://github.com/dcaiafa/lox/releases/download/v0.12.0/lox_Linux_i386.tar.gz -> ${P}-lox_Linux_i386.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-lox_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-lox_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-lox_Linux_i386.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "lox" "lox" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "lox" "lox" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "lox" "lox" || die "Failed to install Binary"
  fi
}

