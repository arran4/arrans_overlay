# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: c8418404ea47fabad55d2956a02dc5759d538fd6
#   workflow: .github/workflows/app-misc-gocdm-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="The Console Display Manager (Go Port)"
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/gocdm"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/gocdm/releases/download/v0.0.26/gocdm_0.0.26_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-gocdm_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/gocdm/releases/download/v0.0.26/gocdm_0.0.26_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-gocdm_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="GNU General Public License v2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-gocdm_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-gocdm_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"gocdm" \
			"gocdm" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"gocdm" \
			"gocdm" \
			|| die "Failed to install Binary"
	fi
}
