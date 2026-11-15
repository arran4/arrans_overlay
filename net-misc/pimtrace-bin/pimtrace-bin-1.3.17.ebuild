# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 1b69dd1b21f52e1cc34ebb763f82a3a6a8bef4c9
#   workflow: .github/workflows/net-misc-pimtrace-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="A CLI tool for preforming queries on ical and csv files"
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/pimtrace/releases/download/v1.3.17/pimtrace_1.3.17_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-pimtrace_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/pimtrace/releases/download/v1.3.17/pimtrace_1.3.17_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-pimtrace_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="Other"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-pimtrace_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-pimtrace_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"csvtrace" \
			"csvtrace" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"csvtrace" \
			"csvtrace" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		dodoc "readme.MD" || die "Failed to install document readme.MD"
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		dodoc "readme.MD" || die "Failed to install document readme.MD"
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		dodoc "readme.MD" || die "Failed to install document readme.MD"
	fi
}
