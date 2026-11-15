# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 1b69dd1b21f52e1cc34ebb763f82a3a6a8bef4c9
#   workflow: .github/workflows/dev-util-editorconfig-guesser-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Generates reasonable .editorconfig files for source files."
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/editorconfig-guesser/releases/download/v1.0.3/ecguess_1.0.3_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-ecguess_${PV}_linux_amd64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/arran4/editorconfig-guesser/releases/download/v1.0.3/ecguess_1.0.3_linux_armv7.tar.gz "
SRC_URI+=" -> ${P}-ecguess_${PV}_linux_armv7.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/editorconfig-guesser/releases/download/v1.0.3/ecguess_1.0.3_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-ecguess_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-ecguess_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-ecguess_${PV}_linux_armv7.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-ecguess_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"ecguess" \
			"ecguess" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"ecguess" \
			"ecguess" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"ecguess" \
			"ecguess" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		if use amd64; then
			dodoc "LICENSE" || die "Failed to install document LICENSE"
			dodoc "readme.md" || die "Failed to install document readme.md"
		fi
		if use arm; then
			dodoc "LICENSE" || die "Failed to install document LICENSE"
			dodoc "readme.md" || die "Failed to install document readme.md"
			dodoc "LICENSE" || die "Failed to install document LICENSE"
			dodoc "readme.md" || die "Failed to install document readme.md"
		fi
		if use arm64; then
			dodoc "LICENSE" || die "Failed to install document LICENSE"
			dodoc "readme.md" || die "Failed to install document readme.md"
		fi
	fi
}
