# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 09682f711d9476ec2da807466dd2ead7017dbba2
#   workflow: .github/workflows/sys-apps-lxa-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="A Linux-first file listing and inspection tool focused on "
DESCRIPTION+="extended attributes"
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/lxa"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/lxa/releases/download/v0.0.6/lxa_0.0.6_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-lxa_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/lxa/releases/download/v0.0.6/lxa_0.0.6_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-lxa_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-lxa_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-lxa_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"lxa" \
			"lxa" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"lxa" \
			"lxa" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "README.md" || die "Failed to install document README.md"
	fi
}
