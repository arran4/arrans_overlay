# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 0ff12b4b7d04bb29b34bfaf8dbe0f566acb742d6
#   workflow: .github/workflows/app-admin-arrans-overlay-workflow-builder-bin-up
#             date.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="A gentoo overlay ebuild workflow builder generator for -bin with "
DESCRIPTION+="a special purpose handler for .appimage binary files"
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/arrans_overlay_workflow_builder/releases/download/v0.1.50/arrans_overlay_workflow_builder_0.1.50_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-arrans_overlay_workflow_builder_${PV}_linux_amd64.tar.gz  ) "
SRC_URI+=" "
LICENSE=""
LICENSE+="unknown"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-arrans_overlay_workflow_builder_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"overlay_workflow_builder_generator" \
			"overlay_workflow_builder_generator" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "readme.md" || die "Failed to install document readme.md"
	fi
}
