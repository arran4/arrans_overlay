EAPI=8

inherit binchecks

DESCRIPTION="A modern terminal multiplexer with classic MS-DOS aesthetic, built with Rust."
HOMEPAGE="https://github.com/alejandroqh/term39"

SRC_URI="
	amd64? ( https://github.com/alejandroqh/term39/releases/download/v${PV}/term39-v${PV}-linux-x86_64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/alejandroqh/term39/releases/download/v${PV}/term39-v${PV}-linux-aarch64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip"
QA_PREBUILT="*"

src_install() {
	dobin term39
}
