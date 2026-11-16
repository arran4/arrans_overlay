# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 4ca157376c17ea4f35c761acf36253be528fa99f
#   workflow: .github/workflows/net-misc-reddit-tui-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="A lightweight terminal application for browsing Reddit from your "
DESCRIPTION+="command line."
HOMEPAGE=""
HOMEPAGE+="https://github.com/tonymajestro/reddit-tui"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/tonymajestro/reddit-tui/releases/download/v0.3.9/reddit-tui_Linux_x86_64.tar.gz "
SRC_URI+=" -> ${P}-reddit-tui_Linux_x86_64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/tonymajestro/reddit-tui/releases/download/v0.3.9/reddit-tui_Linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-reddit-tui_Linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-reddit-tui_Linux_x86_64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-reddit-tui_Linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"reddittui" \
			"reddittui" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"reddittui" \
			"reddittui" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		if use amd64; then
			dodoc "LICENSE.txt" || die "Failed to install document LICENSE.txt"
			dodoc "README.md" || die "Failed to install document README.md"
		fi
	fi
}
