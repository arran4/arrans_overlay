# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-superfile-bin-update.yaml
EAPI=8
DESCRIPTION="Pretty fancy and modern terminal file manager"
HOMEPAGE="https://superfile.netlify.app"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/yorukot/superfile/releases/download/v1.4.0/superfile-linux-v1.4.0-amd64.tar.gz -> ${P}-superfile-linux-v1.4.0-amd64.tar.gz  )  
  arm64? (  https://github.com/yorukot/superfile/releases/download/v1.4.0/superfile-linux-v1.4.0-arm64.tar.gz -> ${P}-superfile-linux-v1.4.0-arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-superfile-linux-v1.4.0-amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-superfile-linux-v1.4.0-arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "./dist/superfile-linux-v1.1.4-amd64/spf" "spf" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "./dist/superfile-linux-v1.1.4-arm64/spf" "spf" || die "Failed to install Binary"
  fi
}

