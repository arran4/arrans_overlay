EAPI=8

inherit git-r3

DESCRIPTION="Main game repository for Beyond All Reason"
HOMEPAGE="https://github.com/beyond-all-reason/Beyond-All-Reason"
EGIT_REPO_URI="https://github.com/beyond-all-reason/Beyond-All-Reason.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
PROPERTIES="live"
RESTRICT="network-sandbox"

BDEPEND="
	net-misc/curl
"
DEPEND="
	dev-lang/lua:5.1
"
RDEPEND="${DEPEND}"

src_compile() {
	einfo "Beyond All Reason uses lux for package management"
	# Instead of using install.sh from curl, use the exact cargo-binstall release
	# used for testing since the test unit specifically installs lux-cli via cargo-binstall
	curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh > "${T}/install.sh"
	sh "${T}/install.sh"
	"${HOME}/.cargo/bin/cargo-binstall" --no-confirm --version 0.28.3 --install-path "${T}" lux-cli

	export PATH="${T}:${PATH}"
	einfo "Updating Lux dependencies"
	lux --max-jobs=2 update || die "Failed to fetch dependencies via lux"
}

src_install() {
	insinto "/usr/share/games/beyond-all-reason"
	# Install only necessary folders and files to avoid temporary artifacts
	# such as .git, lux.toml, etc, but it requires everything for .sdd execution.
	# Actually, spring expects the full repository minus development files.
	# Let's remove .git and install everything in the source root
	rm -rf .git
	doins -r *
}
