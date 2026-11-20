# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 860539d9466c895864f3a4827cdf572f8c318551
#   workflow: .github/workflows/app-misc-superfile-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Pretty fancy and modern terminal file manager"
HOMEPAGE=""
HOMEPAGE+="https://superfile.netlify.app"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/yorukot/superfile/releases/download/v1.6.1/superfile-linux-v1.6.1-amd64.tar.gz "
SRC_URI+=" -> ${P}-superfile-linux-v1.6.1-amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/yorukot/superfile/releases/download/v1.6.1/superfile-linux-v1.6.1-arm64.tar.gz "
SRC_URI+=" -> ${P}-superfile-linux-v1.6.1-arm64.tar.gz  )  "
LICENSE=""
LICENSE+="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-superfile-linux-v1.6.1-amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-superfile-linux-v1.6.1-arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"./dist/superfile-linux-${tag}-amd64/spf" \
			"spf" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"./dist/superfile-linux-${tag}-arm64/spf" \
			"spf" \
			|| die "Failed to install Binary"
	fi
}
