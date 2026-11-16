# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: a328b554b327d418739274bc326f4269ce045236
#   workflow: .github/workflows/net-misc-podcast-cdr-manager-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="CLI tool to help manage podcast subscriptions for burning to "
DESCRIPTION+="CDROMs / CDR / CDRW"
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/podcast-cdr-manager"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/podcast-cdr-manager/releases/download/v0.0.9/podcastcdrmanager_0.0.9_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-podcastcdrmanager_${PV}_linux_amd64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/arran4/podcast-cdr-manager/releases/download/v0.0.9/podcastcdrmanager_0.0.9_linux_armv6.tar.gz "
SRC_URI+=" -> ${P}-podcastcdrmanager_${PV}_linux_armv6.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/podcast-cdr-manager/releases/download/v0.0.9/podcastcdrmanager_0.0.9_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-podcastcdrmanager_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="unknown"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-podcastcdrmanager_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-podcastcdrmanager_${PV}_linux_armv6.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-podcastcdrmanager_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"podcastcdrmanager" \
			"podcastcdrmanager" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"podcastcdrmanager" \
			"podcastcdrmanager" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"podcastcdrmanager" \
			"podcastcdrmanager" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "readme.md" || die "Failed to install document readme.md"
	fi
}
