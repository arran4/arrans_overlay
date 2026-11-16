# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 600e495413ed260e39f7466ca92b1bb35dfbb3c1
#   workflow: .github/workflows/app-misc-dua-cli-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="View disk space usage and delete unwanted data, fast."
HOMEPAGE=""
HOMEPAGE+="https://lib.rs/crates/dua-cli"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/Byron/dua-cli/releases/download/v3.0.3/dua-v3.0.3-x86_64-unknown-linux-musl.tar.gz "
SRC_URI+=" -> ${P}-dua-v3.0.3-x86_64-unknown-linux-musl.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/Byron/dua-cli/releases/download/v3.0.3/dua-v3.0.3-arm-unknown-linux-gnueabihf.tar.gz "
SRC_URI+=" -> ${P}-dua-v3.0.3-arm-unknown-linux-gnueabihf.tar.gz  )   arm64? ( "
SRC_URI+="  "
SRC_URI+="https://github.com/Byron/dua-cli/releases/download/v3.0.3/dua-v3.0.3-aarch64-unknown-linux-musl.tar.gz "
SRC_URI+=" -> ${P}-dua-v3.0.3-aarch64-unknown-linux-musl.tar.gz  )  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""
RDEPEND+="sys-devel/gcc "

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-dua-v3.0.3-x86_64-unknown-linux-musl.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-dua-v3.0.3-arm-unknown-linux-gnueabihf.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-dua-v3.0.3-aarch64-unknown-linux-musl.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"dua-v2.29.2-x86_64-unknown-linux-musl/dua" \
			"dua" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"dua-v2.29.2-arm-unknown-linux-gnueabihf/dua" \
			"dua" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"dua-v2.29.2-aarch64-unknown-linux-musl/dua" \
			"dua" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		if use amd64; then
			newdoc "dua-v2.29.2-x86_64-unknown-linux-musl/LICENSE" "dua-${TAG}-LICENSE" || die "Failed to install document dua-${TAG}-LICENSE"
			newdoc "dua-v2.29.2-x86_64-unknown-linux-musl/README.md" "dua-${TAG}-README.md" || die "Failed to install document dua-${TAG}-README.md"
			newdoc "dua-v2.29.2-x86_64-unknown-linux-musl/CHANGELOG.md" "dua-${TAG}-CHANGELOG.md" || die "Failed to install document dua-${TAG}-CHANGELOG.md"
		fi
		if use arm; then
			newdoc "dua-v2.29.2-arm-unknown-linux-gnueabihf/LICENSE" "dua-${TAG}-LICENSE" || die "Failed to install document dua-${TAG}-LICENSE"
			newdoc "dua-v2.29.2-arm-unknown-linux-gnueabihf/README.md" "dua-${TAG}-README.md" || die "Failed to install document dua-${TAG}-README.md"
			newdoc "dua-v2.29.2-arm-unknown-linux-gnueabihf/CHANGELOG.md" "dua-${TAG}-CHANGELOG.md" || die "Failed to install document dua-${TAG}-CHANGELOG.md"
		fi
		if use arm64; then
			newdoc "dua-v2.29.2-aarch64-unknown-linux-musl/LICENSE" "dua-${TAG}-LICENSE" || die "Failed to install document dua-${TAG}-LICENSE"
			newdoc "dua-v2.29.2-aarch64-unknown-linux-musl/README.md" "dua-${TAG}-README.md" || die "Failed to install document dua-${TAG}-README.md"
			newdoc "dua-v2.29.2-aarch64-unknown-linux-musl/CHANGELOG.md" "dua-${TAG}-CHANGELOG.md" || die "Failed to install document dua-${TAG}-CHANGELOG.md"
		fi
	fi
}
