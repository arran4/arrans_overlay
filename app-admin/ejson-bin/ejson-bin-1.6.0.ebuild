# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: a8c9bba927be93391df01b9a47548f9cca75d8ba
#   workflow: .github/workflows/app-admin-ejson-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="EJSON is a small library to manage encrypted secrets using "
DESCRIPTION+="asymmetric encryption."
HOMEPAGE=""
HOMEPAGE+="https://github.com/Shopify/ejson"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/Shopify/ejson/releases/download/v1.6.0/ejson_1.6.0_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-ejson_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/Shopify/ejson/releases/download/v1.6.0/ejson_1.6.0_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-ejson_${PV}_linux_arm64.tar.gz  )  "
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
		unpack "${DISTDIR}/${P}-ejson_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-ejson_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"ejson" \
			"ejson" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"ejson" \
			"ejson" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "CHANGELOG.md" || die "Failed to install document CHANGELOG.md"
		dodoc "LICENSE.txt" || die "Failed to install document LICENSE.txt"
		dodoc "README.md" || die "Failed to install document README.md"
	fi
}
