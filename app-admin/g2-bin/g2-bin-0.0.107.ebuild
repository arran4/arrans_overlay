# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: ffc773d30734dab7e6e763349f4b4f6317c741d9
#   workflow: .github/workflows/app-admin-g2-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="g2 Gentoo Tools"
HOMEPAGE=""
HOMEPAGE+="https://wiki.gentoo.org/wiki/User:Arran4"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/g2/releases/download/v0.0.107/g2_0.0.107_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-g2_${PV}_linux_amd64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/arran4/g2/releases/download/v0.0.107/g2_0.0.107_linux_armv6.tar.gz "
SRC_URI+=" -> ${P}-g2_${PV}_linux_armv6.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/g2/releases/download/v0.0.107/g2_0.0.107_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-g2_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="unknown"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-g2_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-g2_${PV}_linux_armv6.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-g2_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"g2" \
			"g2" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"g2" \
			"g2" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"g2" \
			"g2" \
			|| die "Failed to install Binary"
	fi
}
