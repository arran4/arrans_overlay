# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-go-goreleaser-bin-update.yaml
EAPI=8
DESCRIPTION="Deliver Go binaries as fast and easily as possible"
HOMEPAGE="https://goreleaser.com"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
IUSE=" man doc bash fish zsh"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/goreleaser/goreleaser/releases/download/v2.12.6/goreleaser_Linux_x86_64.tar.gz -> ${P}-goreleaser_Linux_x86_64.tar.gz  )  
  arm? (  https://github.com/goreleaser/goreleaser/releases/download/v2.12.6/goreleaser_Linux_armv7.tar.gz -> ${P}-goreleaser_Linux_armv7.tar.gz  )  
  arm64? (  https://github.com/goreleaser/goreleaser/releases/download/v2.12.6/goreleaser_Linux_arm64.tar.gz -> ${P}-goreleaser_Linux_arm64.tar.gz  )  
  ppc64? (  https://github.com/goreleaser/goreleaser/releases/download/v2.12.6/goreleaser_Linux_ppc64.tar.gz -> ${P}-goreleaser_Linux_ppc64.tar.gz  )  
  x86? (  https://github.com/goreleaser/goreleaser/releases/download/v2.12.6/goreleaser_Linux_i386.tar.gz -> ${P}-goreleaser_Linux_i386.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-goreleaser_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-goreleaser_Linux_armv7.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-goreleaser_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use ppc64; then
    unpack "${DISTDIR}/${P}-goreleaser_Linux_ppc64.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-goreleaser_Linux_i386.tar.gz" || die "Can't unpack archive file"
  fi
  if use man; then
    gzip -d "manpages/goreleaser.1.gz" || die "Failed to decompress manual page goreleaser.1"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "goreleaser" "goreleaser" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "goreleaser" "goreleaser" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "goreleaser" "goreleaser" || die "Failed to install Binary"
  fi
  if use ppc64; then
    newexe "goreleaser" "goreleaser" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "goreleaser" "goreleaser" || die "Failed to install Binary"
  fi
  if use bash; then
    insinto "/usr/share/bash-completion/completions"
    newins "completions/goreleaser.bash" "goreleaser.bash" || die "Failed to bash completion file"
  fi
  if use fish; then
    insinto "/usr/share/fish/vendor_completions.d"
    newins "completions/goreleaser.fish" "goreleaser.fish" || die "Failed to bash completion file"
  fi
  if use zsh; then
    insinto "/usr/share/zsh/site-functions"
    newins "completions/goreleaser.zsh" "goreleaser.zsh" || die "Failed to bash completion file"
  fi
  if use man; then
    newman "manpages/goreleaser.1" "goreleaser.1" || die "Failed to install manual page goreleaser.1"
  fi
  if use doc; then
    newdoc "LICENSE.md" "LICENSE.md" || die "Failed to install document LICENSE.md"
    newdoc "README.md" "README.md" || die "Failed to install document README.md"
  fi
}

