# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-admin-arrans-overlay-workflow-builder-bin-update.yaml
EAPI=8
DESCRIPTION="A gentoo overlay ebuild workflow builder generator for -bin with a special purpose handler for .appimage binary files"
HOMEPAGE=""
SRC_URI="
  amd64? (  https://github.com/arran4/arrans_overlay_workflow_builder/releases/download/v${PV}/arrans_overlay_workflow_builder_${PV}_linux_amd64.tar.gz -> ${P}-arrans_overlay_workflow_builder_${PV}_linux_amd64.tar.gz  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-arrans_overlay_workflow_builder_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "overlay_workflow_builder_generator" "overlay_workflow_builder_generator" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
  fi
}
