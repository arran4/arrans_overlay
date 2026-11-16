# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: adfea4b3e6ad3864909b7f2e3d368eb3aac81b91
#   workflow: .github/workflows/www-apps-pagefind-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Static low-bandwidth search at scale"
HOMEPAGE=""
HOMEPAGE+="https://pagefind.app"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/CloudCannon/pagefind/releases/download/v1.6.0/pagefind-v1.6.0-x86_64-unknown-linux-musl.tar.gz "
SRC_URI+=" -> ${P}-pagefind-v1.6.0-x86_64-unknown-linux-musl.tar.gz  )   "
SRC_URI+="amd64? (   "
SRC_URI+="https://github.com/CloudCannon/pagefind/releases/download/v1.6.0/pagefind_extended-v1.6.0-x86_64-unknown-linux-musl.tar.gz "
SRC_URI+=" -> ${P}-pagefind_extended-v1.6.0-x86_64-unknown-linux-musl.tar.gz  "
SRC_URI+=")   arm64? (   "
SRC_URI+="https://github.com/CloudCannon/pagefind/releases/download/v1.6.0/pagefind-v1.6.0-aarch64-unknown-linux-musl.tar.gz "
SRC_URI+=" -> ${P}-pagefind-v1.6.0-aarch64-unknown-linux-musl.tar.gz  )   "
SRC_URI+="arm64? (   "
SRC_URI+="https://github.com/CloudCannon/pagefind/releases/download/v1.6.0/pagefind_extended-v1.6.0-aarch64-unknown-linux-musl.tar.gz "
SRC_URI+=" -> ${P}-pagefind_extended-v1.6.0-aarch64-unknown-linux-musl.tar.gz  "
SRC_URI+=")  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-pagefind-v1.6.0-x86_64-unknown-linux-musl.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use amd64; then
		unpack "${DISTDIR}/${P}-pagefind_extended-v1.6.0-x86_64-unknown-linux-musl.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-pagefind-v1.6.0-aarch64-unknown-linux-musl.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-pagefind_extended-v1.6.0-aarch64-unknown-linux-musl.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"pagefind" \
			"pagefind" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"pagefind" \
			"pagefind" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"pagefind_extended" \
			"pagefind_extended" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"pagefind_extended" \
			"pagefind_extended" \
			|| die "Failed to install Binary"
	fi
}
