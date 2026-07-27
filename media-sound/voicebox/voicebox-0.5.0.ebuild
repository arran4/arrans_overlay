EAPI=8

inherit desktop

DESCRIPTION="Open source voice cloning. Local-first. Free forever."
HOMEPAGE="https://voicebox.sh"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/jamiepine/voicebox.git"
else
	SRC_URI="https://github.com/jamiepine/voicebox/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="MIT"
SLOT="0"

PROPERTIES="live"

DEPEND="
	dev-lang/rust
	dev-lang/python
	net-libs/webkit-gtk:4.1
	x11-libs/gtk+:3
	dev-libs/openssl
	net-libs/nodejs
"
RDEPEND="${DEPEND}"
BDEPEND="
	sys-apps/just
	sys-apps/bun
"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	else
		default
	fi
}

src_compile() {
	export PATH="${WORKDIR}/.cargo/bin:${PATH}"
	export CARGO_HOME="${WORKDIR}/.cargo"

	just setup || die "just setup failed"
	bun run setup:dev || die "setup dev failed"
	just build || die "just build failed"
}

src_install() {
	dodir /opt/voicebox
	cp -r tauri/src-tauri/target/release/bundle/* "${ED}/opt/voicebox" || die "failed to copy bundle"

	dosym /opt/voicebox/voicebox /usr/bin/voicebox

	make_desktop_entry "/usr/bin/voicebox" "Voicebox" "/opt/voicebox/Contents/Resources/icon.icns" "AudioVideo"
}
