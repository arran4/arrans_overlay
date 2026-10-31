# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Go CLI and library for extracting website metadata"
HOMEPAGE="https://github.com/arran4/header"

BASE_URL="https://github.com/arran4/header/releases/download/v\${PV}"

SRC_URI="
	amd64? (
		\${BASE_URL}/header_\${PV}_linux_amd64.tar.gz -> \${P}-header_\${PV}_linux_amd64.tar.gz
	)
	arm64? (
		\${BASE_URL}/header_\${PV}_linux_arm64.tar.gz -> \${P}-header_\${PV}_linux_arm64.tar.gz
	)
	x86? (
		\${BASE_URL}/header_\${PV}_linux_386.tar.gz -> \${P}-header_\${PV}_linux_386.tar.gz
	)
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc"
RESTRICT="mirror"

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-header_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-header_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-header_${PV}_linux_386.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"header" \
			"header" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"header" \
			"header" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"header" \
			"header" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		dodoc "README.md" || die "Failed to install document README.md"
	fi
}
