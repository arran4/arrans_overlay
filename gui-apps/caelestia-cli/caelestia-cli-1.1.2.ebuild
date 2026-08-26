# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{13..14} )

inherit distutils-r1 shell-completion

DESCRIPTION="CLI for the Caelestia shell (scheme, screenshot, record, etc)"
HOMEPAGE="https://github.com/caelestia-dots/cli"
SRC_URI="https://github.com/caelestia-dots/cli/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/cli-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND+="
	dev-python/pillow[${PYTHON_USEDEP}]
	>=dev-python/materialyoucolor-3.0.0[${PYTHON_USEDEP}]
	app-misc/cliphist
	dev-vcs/git
	gui-apps/fuzzel
	gui-apps/grim
	gui-apps/slurp
	gui-apps/swappy
	gui-apps/wl-clipboard
	media-video/gpu-screen-recorder
	x11-libs/libnotify
"
# hatch-vcs derives the version from git metadata,
# which a release tarball lacks.
BDEPEND+="
	$(python_gen_cond_dep 'dev-python/hatch-vcs[${PYTHON_USEDEP}]')
"

PATCHES=(
	# Add \`caelestia install --no-packages\` so the dotfiles can
	# be deployed
	# without the Arch-only AUR-helper package step
	# (upstream install always
	# invokes an AUR helper, which does not exist on Gentoo).
	"${FILESDIR}/${PN}-dots-only.patch"
	# Report installed Caelestia package versions through Portage
	# on Gentoo,
	# equivalent to upstream's pacman-based diagnostics on Arch.
	"${FILESDIR}/${PN}-non-arch-version.patch"
)

# Feed the version to hatch-vcs (setuptools_scm) since there is
# no .git here.
export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"

src_install() {
	distutils-r1_src_install
	dofishcomp completions/caelestia.fish
}

pkg_postinst() {
	elog "Deploy the Caelestia dotfiles on Gentoo with:"
	elog "    caelestia install --no-packages"
	elog "This deploys the config files (fetched from upstream git) and"
	elog "skips the"
	elog "Arch AUR-helper package step (added by"
	elog "${PN}-dots-only.patch). Plain"
	elog "'caelestia install' fails here; install deps via Portage instead"
	elog "(emerge gui-apps/caelestia-meta). Update later with:"
	elog "caelestia update"
	elog
	elog "Your ~/.config/caelestia/ overrides (hypr-user.lua,"
	elog "hypr-vars.lua,"
	elog "user-config.fish) are preserved -- they are not in the"
	elog "upstream tree."
	elog
	elog "This replaces any old 'uv tool' install: remove"
	elog "~/.local/share/uv/tools/caelestia and the"
	elog "/usr/local/bin/caelestia symlink."
}

src_prepare() {
	default
		sed -i \
			-e 's|"qs", "-c", "caelestia"|"qs", "-p", \
			"/usr/share/quickshell/caelestia"|g' \
		src/caelestia/subcommands/*.py || die
}
