# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 1b69dd1b21f52e1cc34ebb763f82a3a6a8bef4c9
#   workflow: .github/workflows/dev-util-layerx-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Interactive Docker image layer inspector"
HOMEPAGE=""
HOMEPAGE+="https://github.com/deveshctl/layerx"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/deveshctl/layerx/releases/download/v1.6.4/layerx_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-layerx_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/deveshctl/layerx/releases/download/v1.6.4/layerx_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-layerx_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-layerx_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-layerx_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"layerx" \
			"layerx" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"layerx" \
			"layerx" \
			|| die "Failed to install Binary"
	fi
}
