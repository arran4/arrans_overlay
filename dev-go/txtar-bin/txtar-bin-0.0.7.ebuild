# Generated using: https://github.com/arran4/arrans_overlay_workflow_builder 0.1.37 Github Binary Release current.config 2026-08-08 02:11:41.914576776 +0000 UTC m=+0.008115703
EAPI=8

DESCRIPTION="txtar enhanced and with a cli tool"
HOMEPAGE="https://github.com/arran4/txtar"
SRC_URI="
	amd64? ( https://github.com/arran4/txtar/releases/download/v${PV}/txtar_${PV}_linux_amd64.tar.gz -> ${P}-txtar_${PV}_linux_amd64.tar.gz )
	arm64? ( https://github.com/arran4/txtar/releases/download/v${PV}/txtar_${PV}_linux_arm64.tar.gz -> ${P}-txtar_${PV}_linux_arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="BSD-3-Clause"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"
DEPEND="
"
RDEPEND="${DEPEND}"
BDEPEND=""

QA_PREBUILT="
	usr/bin/txtar
"

src_unpack() {
	if use amd64; then
		unpack ${P}-txtar_${PV}_linux_amd64.tar.gz
	fi
	if use arm64; then
		unpack ${P}-txtar_${PV}_linux_arm64.tar.gz
	fi
}

src_install() {
	if use amd64; then
		dobin txtar
		dodoc LICENSE
		dodoc README.md
	fi
	if use arm64; then
		dobin txtar
	fi
}
