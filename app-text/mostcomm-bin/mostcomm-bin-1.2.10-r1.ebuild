# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 4bd8af35e376edd34ff823b818cd4de79db726f3
#   workflow: .github/workflows/app-text-mostcomm-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="A cli utility for finding the most common and sorting by length, "
DESCRIPTION+="lines-sets in a text file"
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/mostcomm/releases/download/v1.2.10/mostcomm_1.2.10_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-mostcomm_${PV}_linux_amd64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/arran4/mostcomm/releases/download/v1.2.10/mostcomm_1.2.10_linux_armv7.tar.gz "
SRC_URI+=" -> ${P}-mostcomm_${PV}_linux_armv7.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/mostcomm/releases/download/v1.2.10/mostcomm_1.2.10_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-mostcomm_${PV}_linux_arm64.tar.gz  )  "
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
		unpack "${DISTDIR}/${P}-mostcomm_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-mostcomm_${PV}_linux_armv7.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-mostcomm_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"mostcomm" \
			"mostcomm" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"mostcomm" \
			"mostcomm" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"mostcomm" \
			"mostcomm" \
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
