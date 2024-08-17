# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-pimtrace-bin-update.yaml
EAPI=8
DESCRIPTION="A CLI tool for preforming queries on ical and csv files"
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND="sys-libs/glibc "
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/pimtrace/releases/download/v1.3.6/pimtrace_${PV}_linux_amd64.tar.gz -> ${P}-pimtrace_${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/arran4/pimtrace/releases/download/v1.3.6/pimtrace_${PV}_linux_arm64.tar.gz -> ${P}-pimtrace_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-pimtrace_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-pimtrace_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "csvtrace" "csvtrace" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "csvtrace" "csvtrace" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
    newdoc "readme.MD" "readme.MD" || die "Failed to install document readme.MD"
    newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
    newdoc "readme.MD" "readme.MD" || die "Failed to install document readme.MD"
    newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
    newdoc "readme.MD" "readme.MD" || die "Failed to install document readme.MD"
  fi
}

