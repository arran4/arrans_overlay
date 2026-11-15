# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 1b69dd1b21f52e1cc34ebb763f82a3a6a8bef4c9
#   workflow: .github/workflows/dev-util-ast-grep-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Structural search, linting and rewriting for source code"
HOMEPAGE=""
HOMEPAGE+="https://ast-grep.github.io/"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/ast-grep/ast-grep/releases/download/0.51.2/app-x86_64-unknown-linux-gnu.zip "
SRC_URI+=" -> ${P}-app-x86_64-unknown-linux-gnu.zip  )   arm64? (   "
SRC_URI+="https://github.com/ast-grep/ast-grep/releases/download/0.51.2/app-aarch64-unknown-linux-gnu.zip "
SRC_URI+=" -> ${P}-app-aarch64-unknown-linux-gnu.zip  )  "
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
		unpack "${DISTDIR}/${P}-app-x86_64-unknown-linux-gnu.zip" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-app-aarch64-unknown-linux-gnu.zip" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"ast-grep" \
			"ast-grep" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"ast-grep" \
			"ast-grep" \
			|| die "Failed to install Binary"
	fi
}
