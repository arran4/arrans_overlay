# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-dua-cli-bin-update.yaml
EAPI=8
DESCRIPTION="View disk space usage and delete unwanted data, fast."
HOMEPAGE="https://lib.rs/crates/dua-cli"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND="sys-devel/gcc sys-libs/glibc "
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/Byron/dua-cli/releases/download/v2.29.2/dua-v2.29.2-x86_64-unknown-linux-musl.tar.gz -> ${P}-dua-v2.29.2-x86_64-unknown-linux-musl.tar.gz  )  
  arm? (  https://github.com/Byron/dua-cli/releases/download/v2.29.2/dua-v2.29.2-arm-unknown-linux-gnueabihf.tar.gz -> ${P}-dua-v2.29.2-arm-unknown-linux-gnueabihf.tar.gz  )  
  arm64? (  https://github.com/Byron/dua-cli/releases/download/v2.29.2/dua-v2.29.2-aarch64-unknown-linux-musl.tar.gz -> ${P}-dua-v2.29.2-aarch64-unknown-linux-musl.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-dua-v2.29.2-x86_64-unknown-linux-musl.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-dua-v2.29.2-arm-unknown-linux-gnueabihf.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-dua-v2.29.2-aarch64-unknown-linux-musl.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "dua-v2.29.2-x86_64-unknown-linux-musl/dua" "dua" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "dua-v2.29.2-arm-unknown-linux-gnueabihf/dua" "dua" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "dua-v2.29.2-aarch64-unknown-linux-musl/dua" "dua" || die "Failed to install Binary"
  fi
  if use doc; then
    if use amd64; then
      newdoc "dua-v2.29.2-x86_64-unknown-linux-musl/LICENSE" "dua-${TAG}-LICENSE" || die "Failed to install document dua-${TAG}-LICENSE"
      newdoc "dua-v2.29.2-x86_64-unknown-linux-musl/README.md" "dua-${TAG}-README.md" || die "Failed to install document dua-${TAG}-README.md"
      newdoc "dua-v2.29.2-x86_64-unknown-linux-musl/CHANGELOG.md" "dua-${TAG}-CHANGELOG.md" || die "Failed to install document dua-${TAG}-CHANGELOG.md"
    fi
    if use arm; then
      newdoc "dua-v2.29.2-arm-unknown-linux-gnueabihf/LICENSE" "dua-${TAG}-LICENSE" || die "Failed to install document dua-${TAG}-LICENSE"
      newdoc "dua-v2.29.2-arm-unknown-linux-gnueabihf/README.md" "dua-${TAG}-README.md" || die "Failed to install document dua-${TAG}-README.md"
      newdoc "dua-v2.29.2-arm-unknown-linux-gnueabihf/CHANGELOG.md" "dua-${TAG}-CHANGELOG.md" || die "Failed to install document dua-${TAG}-CHANGELOG.md"
    fi
    if use arm64; then
      newdoc "dua-v2.29.2-aarch64-unknown-linux-musl/LICENSE" "dua-${TAG}-LICENSE" || die "Failed to install document dua-${TAG}-LICENSE"
      newdoc "dua-v2.29.2-aarch64-unknown-linux-musl/README.md" "dua-${TAG}-README.md" || die "Failed to install document dua-${TAG}-README.md"
      newdoc "dua-v2.29.2-aarch64-unknown-linux-musl/CHANGELOG.md" "dua-${TAG}-CHANGELOG.md" || die "Failed to install document dua-${TAG}-CHANGELOG.md"
    fi
  fi
}

