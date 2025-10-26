# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-shineyshot-bin-update.yaml
EAPI=8
DESCRIPTION="A simple screenshotting tool with several user modes"
HOMEPAGE="https://github.com/arran4/shineyshot"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/shineyshot/releases/download/v1.0.0/shineyshot_${PV}_Linux_x86_64.tar.gz -> ${P}-shineyshot_${PV}_Linux_x86_64.tar.gz  )  
  arm? (  https://github.com/arran4/shineyshot/releases/download/v1.0.0/shineyshot_${PV}_Linux_armv7.tar.gz -> ${P}-shineyshot_${PV}_Linux_armv7.tar.gz  )  
  arm64? (  https://github.com/arran4/shineyshot/releases/download/v1.0.0/shineyshot_${PV}_Linux_arm64.tar.gz -> ${P}-shineyshot_${PV}_Linux_arm64.tar.gz  )  
  x86? (  https://github.com/arran4/shineyshot/releases/download/v1.0.0/shineyshot_${PV}_Linux_i386.tar.gz -> ${P}-shineyshot_${PV}_Linux_i386.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-shineyshot_${PV}_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-shineyshot_${PV}_Linux_armv7.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-shineyshot_${PV}_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-shineyshot_${PV}_Linux_i386.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "shineyshot" "shineyshot" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "shineyshot" "shineyshot" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "shineyshot" "shineyshot" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "shineyshot" "shineyshot" || die "Failed to install Binary"
  fi
  if use doc; then
    if use amd64; then
      newdoc "README.md" "README.md" || die "Failed to install document README.md"
    fi
    if use arm; then
      newdoc "README.md" "README.md" || die "Failed to install document README.md"
      newdoc "README.md" "README.md" || die "Failed to install document README.md"
    fi
    if use arm64; then
      newdoc "README.md" "README.md" || die "Failed to install document README.md"
    fi
    if use x86; then
      newdoc "README.md" "README.md" || die "Failed to install document README.md"
    fi
  fi
}

