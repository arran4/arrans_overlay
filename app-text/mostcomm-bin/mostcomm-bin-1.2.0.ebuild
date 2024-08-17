# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-text-mostcomm-bin-update.yaml
EAPI=8
DESCRIPTION="A cli utility for finding the most common and sorting by length, lines-sets in a text file"
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/mostcomm/releases/download/v1.2.0/mostcomm_${PV}_linux_amd64.tar.gz -> ${P}-mostcomm_${PV}_linux_amd64.tar.gz  )  
  arm? (  https://github.com/arran4/mostcomm/releases/download/v1.2.0/mostcomm_${PV}_linux_armv7.tar.gz -> ${P}-mostcomm_${PV}_linux_armv7.tar.gz  )  
  arm64? (  https://github.com/arran4/mostcomm/releases/download/v1.2.0/mostcomm_${PV}_linux_arm64.tar.gz -> ${P}-mostcomm_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-mostcomm_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-mostcomm_${PV}_linux_armv7.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-mostcomm_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "mostcomm" "mostcomm" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "mostcomm" "mostcomm" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "mostcomm" "mostcomm" || die "Failed to install Binary"
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

