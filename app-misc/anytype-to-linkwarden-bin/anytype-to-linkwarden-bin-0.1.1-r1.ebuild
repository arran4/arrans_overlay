# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 1a97b37edf27146fcea663568c630230217695e7
#   workflow: .github/workflows/app-misc-anytype-to-linkwarden-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Simple application for migrating AnyType bookmarks to Linkwarden"
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/anytype-to-linkwarden/releases/download/v0.1.1/anytype-to-linkwarden_0.1.1_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-anytype-to-linkwarden_${PV}_linux_amd64.tar.gz  )   arm64? "
SRC_URI+="(   "
SRC_URI+="https://github.com/arran4/anytype-to-linkwarden/releases/download/v0.1.1/anytype-to-linkwarden_0.1.1_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-anytype-to-linkwarden_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="unknown"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-anytype-to-linkwarden_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-anytype-to-linkwarden_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"anytype-to-linkwarden" \
			"anytype-to-linkwarden" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"anytype-to-linkwarden" \
			"anytype-to-linkwarden" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		if use amd64; then
			dodoc "readme.md" || die "Failed to install document readme.md"
			dodoc "readme.md" || die "Failed to install document readme.md"
		fi
		if use arm64; then
			dodoc "readme.md" || die "Failed to install document readme.md"
		fi
	fi
}
