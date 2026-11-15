# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 1b69dd1b21f52e1cc34ebb763f82a3a6a8bef4c9
#   workflow: .github/workflows/app-misc-shineyshot-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="A simple screenshotting tool with several user modes"
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/shineyshot"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/shineyshot/releases/download/v1.0.9/shineyshot_1.0.9_Linux_x86_64.tar.gz "
SRC_URI+=" -> ${P}-shineyshot_${PV}_Linux_x86_64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/arran4/shineyshot/releases/download/v1.0.9/shineyshot_1.0.9_Linux_armv7.tar.gz "
SRC_URI+=" -> ${P}-shineyshot_${PV}_Linux_armv7.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/shineyshot/releases/download/v1.0.9/shineyshot_1.0.9_Linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-shineyshot_${PV}_Linux_arm64.tar.gz  )   x86? (   "
SRC_URI+="https://github.com/arran4/shineyshot/releases/download/v1.0.9/shineyshot_1.0.9_Linux_i386.tar.gz "
SRC_URI+=" -> ${P}-shineyshot_${PV}_Linux_i386.tar.gz  )  "
LICENSE=""
LICENSE+="GNU Affero General Public License v3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-shineyshot_${PV}_Linux_x86_64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-shineyshot_${PV}_Linux_armv7.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-shineyshot_${PV}_Linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-shineyshot_${PV}_Linux_i386.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"shineyshot" \
			"shineyshot" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"shineyshot" \
			"shineyshot" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"shineyshot" \
			"shineyshot" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"shineyshot" \
			"shineyshot" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		if use amd64; then
			dodoc "README.md" || die "Failed to install document README.md"
		fi
		if use arm; then
			dodoc "README.md" || die "Failed to install document README.md"
			dodoc "README.md" || die "Failed to install document README.md"
		fi
		if use arm64; then
			dodoc "README.md" || die "Failed to install document README.md"
		fi
		if use x86; then
			dodoc "README.md" || die "Failed to install document README.md"
		fi
	fi
}
