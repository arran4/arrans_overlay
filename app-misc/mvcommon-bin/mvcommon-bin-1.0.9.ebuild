# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 5837e3256a3f5a74b78aca10d8738d61303af6e6
#   workflow: .github/workflows/app-misc-mvcommon-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Tool for moving files into a folder where they have a common "
DESCRIPTION+="prefix"
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/mvcommon/releases/download/v1.0.9/mvcommon_1.0.9_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-mvcommon_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/mvcommon/releases/download/v1.0.9/mvcommon_1.0.9_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-mvcommon_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="GNU General Public License v3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-mvcommon_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-mvcommon_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"mvcommon" \
			"mvcommon" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"mvcommon" \
			"mvcommon" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		dodoc "readme.md" || die "Failed to install document readme.md"
	fi
}
