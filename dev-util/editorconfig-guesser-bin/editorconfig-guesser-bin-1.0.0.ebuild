# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-editorconfig-guesser-bin-update.yaml
EAPI=8
DESCRIPTION="Generates reasonable .editorconfig files for source files."
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=" ecguess doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/editorconfig-guesser/releases/download/v1.0.0/cards_${PV}_linux_amd64.tar.gz -> ${P}-cards_${PV}_linux_amd64.tar.gz  )  
  arm? ( ecguess? (  https://github.com/arran4/editorconfig-guesser/releases/download/v1.0.0/cards_${PV}_linux_armv7.tar.gz -> ${P}-cards_${PV}_linux_armv7.tar.gz  )  )  
  arm64? (  https://github.com/arran4/editorconfig-guesser/releases/download/v1.0.0/cards_${PV}_linux_arm64.tar.gz -> ${P}-cards_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-cards_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm && use ecguess; then
    unpack "${DISTDIR}/${P}-cards_${PV}_linux_armv7.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-cards_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "ecguess" "ecguess" || die "Failed to install Binary"
  fi
  if use arm && use ecguess; then
    newexe "ecguess" "ecguess" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "ecguess" "ecguess" || die "Failed to install Binary"
  fi
  if use doc; then
    if use amd64; then
      newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
    fi
    if use arm; then
      newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
      newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
    fi
    if use arm64; then
      newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
    fi
  fi
}

