# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 7f635259d799f95952701b8891ef81040983d1e0
#   workflow: .github/workflows/app-text-header-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Go CLI and library for extracting, validating, editing and "
DESCRIPTION+="visualizing website metadata"
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/header"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/header/releases/download/v0.0.6/header_0.0.6_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-header_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/header/releases/download/v0.0.6/header_0.0.6_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-header_${PV}_linux_arm64.tar.gz  )   x86? (   "
SRC_URI+="https://github.com/arran4/header/releases/download/v0.0.6/header_0.0.6_linux_386.tar.gz "
SRC_URI+=" -> ${P}-header_${PV}_linux_386.tar.gz  )  "
LICENSE=""
LICENSE+="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-header_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-header_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-header_${PV}_linux_386.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"header" \
			"header" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"header" \
			"header" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"header" \
			"header" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		dodoc "README.md" || die "Failed to install document README.md"
	fi
}
