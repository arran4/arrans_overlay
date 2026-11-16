# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: fcdc732f8245f3bbaf4ac3f84d8eb5b09f953c70
#   workflow: .github/workflows/net-misc-abc-justin-rss-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="ABC news just-in to rss converter - generated"
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/abc-justin-rss"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/abc-justin-rss/releases/download/v0.0.17/abcjustinrss_0.0.17_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-abcjustinrss_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/abc-justin-rss/releases/download/v0.0.17/abcjustinrss_0.0.17_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-abcjustinrss_${PV}_linux_arm64.tar.gz  )   x86? (   "
SRC_URI+="https://github.com/arran4/abc-justin-rss/releases/download/v0.0.17/abcjustinrss_0.0.17_linux_386.tar.gz "
SRC_URI+=" -> ${P}-abcjustinrss_${PV}_linux_386.tar.gz  )  "
LICENSE=""
LICENSE+="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-abcjustinrss_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-abcjustinrss_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-abcjustinrss_${PV}_linux_386.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"abcjustinrss" \
			"abcjustinrss" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"abcjustinrss" \
			"abcjustinrss" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"abcjustinrss" \
			"abcjustinrss" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		newdoc "readme.md" "README.md" || die "Failed to install document README.md"
	fi
}
