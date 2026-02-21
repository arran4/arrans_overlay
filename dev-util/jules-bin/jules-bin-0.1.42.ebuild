# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Jules, the asynchronous coding agent from Google, in the terminal."
HOMEPAGE="https://jules.google"

# URL logic
# https://storage.googleapis.com/jules-cli/v0.1.42/jules_external_v0.1.42_linux_amd64.tar.gz
SRC_URI="
	amd64? ( https://storage.googleapis.com/jules-cli/v${PV}/jules_external_v${PV}_linux_amd64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://storage.googleapis.com/jules-cli/v${PV}/jules_external_v${PV}_linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
"

LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="sys-libs/glibc"
BDEPEND=""

S="${WORKDIR}"

src_install() {
	dobin jules
	dodoc README.md
}
