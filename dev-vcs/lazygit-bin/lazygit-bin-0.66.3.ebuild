# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 742c65e4ce3b586aac76fb40fae8d5bbee21e76d
#   workflow: .github/workflows/dev-vcs-lazygit-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="simple terminal UI for git commands"
HOMEPAGE=""
HOMEPAGE+="https://github.com/jesseduffield/lazygit"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_x86_64.tar.gz "
SRC_URI+=" -> ${P}-lazygit_${PV}_linux_x86_64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_armv6.tar.gz "
SRC_URI+=" -> ${P}-lazygit_${PV}_linux_armv6.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-lazygit_${PV}_linux_arm64.tar.gz  )   x86? (   "
SRC_URI+="https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_32-bit.tar.gz "
SRC_URI+=" -> ${P}-lazygit_${PV}_linux_32-bit.tar.gz  )  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-lazygit_${PV}_linux_x86_64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-lazygit_${PV}_linux_armv6.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-lazygit_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-lazygit_${PV}_linux_32-bit.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"lazygit" \
			"lazygit" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"lazygit" \
			"lazygit" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"lazygit" \
			"lazygit" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"lazygit" \
			"lazygit" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		dodoc "README.md" || die "Failed to install document README.md"
	fi
}
