# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/www-apps-pagefind-bin-update.yaml
EAPI=8
DESCRIPTION="Static low-bandwidth search at scale"
HOMEPAGE="https://pagefind.app"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/CloudCannon/pagefind/releases/download/v1.1.0/pagefind-v1.1.0-x86_64-unknown-linux-musl.tar.gz -> ${P}-pagefind-v1.1.0-x86_64-unknown-linux-musl.tar.gz  )  
  amd64? (  https://github.com/CloudCannon/pagefind/releases/download/v1.1.0/pagefind_extended-v1.1.0-x86_64-unknown-linux-musl.tar.gz -> ${P}-pagefind_extended-v1.1.0-x86_64-unknown-linux-musl.tar.gz  )  
  arm64? (  https://github.com/CloudCannon/pagefind/releases/download/v1.1.0/pagefind-v1.1.0-aarch64-unknown-linux-musl.tar.gz -> ${P}-pagefind-v1.1.0-aarch64-unknown-linux-musl.tar.gz  )  
  arm64? (  https://github.com/CloudCannon/pagefind/releases/download/v1.1.0/pagefind_extended-v1.1.0-aarch64-unknown-linux-musl.tar.gz -> ${P}-pagefind_extended-v1.1.0-aarch64-unknown-linux-musl.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-pagefind-v1.1.0-x86_64-unknown-linux-musl.tar.gz" || die "Can't unpack archive file"
  fi
  if use amd64; then
    unpack "${DISTDIR}/${P}-pagefind_extended-v1.1.0-x86_64-unknown-linux-musl.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-pagefind-v1.1.0-aarch64-unknown-linux-musl.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-pagefind_extended-v1.1.0-aarch64-unknown-linux-musl.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "pagefind" "pagefind" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "pagefind" "pagefind" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "pagefind_extended" "pagefind_extended" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "pagefind_extended" "pagefind_extended" || die "Failed to install Binary"
  fi
}

