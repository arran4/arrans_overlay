# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-tuios-bin-update.yaml
EAPI=8
DESCRIPTION="Terminal UI OS (Terminal Multiplexer)"
HOMEPAGE="https://github.com/Gaurav-Gosain/tuios"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/Gaurav-Gosain/tuios/releases/download/v0.0.26/tuios_${PV}_Linux_x86_64.tar.gz -> ${P}-tuios_${PV}_Linux_x86_64.tar.gz  )  
  arm? (  https://github.com/Gaurav-Gosain/tuios/releases/download/v0.0.26/tuios_${PV}_Linux_armv7.tar.gz -> ${P}-tuios_${PV}_Linux_armv7.tar.gz  )  
  arm64? (  https://github.com/Gaurav-Gosain/tuios/releases/download/v0.0.26/tuios_${PV}_Linux_arm64.tar.gz -> ${P}-tuios_${PV}_Linux_arm64.tar.gz  )  
  x86? (  https://github.com/Gaurav-Gosain/tuios/releases/download/v0.0.26/tuios_${PV}_Linux_i386.tar.gz -> ${P}-tuios_${PV}_Linux_i386.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-tuios_${PV}_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-tuios_${PV}_Linux_armv7.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-tuios_${PV}_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-tuios_${PV}_Linux_i386.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "tuios" "tuios" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "tuios" "tuios" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "tuios" "tuios" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "tuios" "tuios" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
    newdoc "README.md" "README.md" || die "Failed to install document README.md"
  fi
}

