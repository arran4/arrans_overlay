# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: e7109c9f4c4e5edddd5c44101b99c8459bcb825e
#   workflow: .github/workflows/app-admin-g2-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="g2 Gentoo Tools"
HOMEPAGE=""
HOMEPAGE+="https://wiki.gentoo.org/wiki/User:Arran4"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/g2/releases/download/v0.0.108/g2_0.0.108_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-g2_${PV}_linux_amd64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/arran4/g2/releases/download/v0.0.108/g2_0.0.108_linux_armv6.tar.gz "
SRC_URI+=" -> ${P}-g2_${PV}_linux_armv6.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/g2/releases/download/v0.0.108/g2_0.0.108_linux_arm64.tar.gz "
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
