# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-editor-bin-update.yaml
EAPI=8
DESCRIPTION="Source code editor in pure Go."
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/jmigpin/editor/releases/download/v3.11.0/editor${PV}-linux-amd64.tar.gz -> ${P}-editor${PV}-linux-amd64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-editor${PV}-linux-amd64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "editor" "editor" || die "Failed to install Binary"
  fi
}

