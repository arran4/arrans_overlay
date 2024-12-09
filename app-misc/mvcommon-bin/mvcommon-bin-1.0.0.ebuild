# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-mvcommon-bin-update.yaml
EAPI=8
DESCRIPTION="Tool for moving files into a folder where they have a common prefix"
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/mvcommon/releases/download/v1.0.0/mvcommon_${PV}_linux_amd64.tar.gz -> ${P}-mvcommon_${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/arran4/mvcommon/releases/download/v1.0.0/mvcommon_${PV}_linux_arm64.tar.gz -> ${P}-mvcommon_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-mvcommon_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-mvcommon_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "mvcommon" "mvcommon" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "mvcommon" "mvcommon" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
    newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
  fi
}

