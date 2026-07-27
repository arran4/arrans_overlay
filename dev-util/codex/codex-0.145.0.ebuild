# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-codex-update.yaml
EAPI=8

CRATES="
"

inherit cargo

DESCRIPTION="Lightweight coding agent that runs in your terminal"
HOMEPAGE="https://github.com/openai/codex"
SRC_URI="https://github.com/openai/codex/archive/refs/tags/rust-v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

DEPEND="
	dev-db/sqlite:3
	dev-libs/openssl:=
	dev-libs/wayland
	media-libs/alsa-lib
	sys-apps/dbus
"
RDEPEND=""
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/codex-rust-v${PV}/codex-rs"

src_unpack() {
	default
	cargo_src_unpack
}


src_install() {
	cargo_src_install
}
