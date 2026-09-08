# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg desktop

DESCRIPTION="Anytype Desktop application"
HOMEPAGE="https://github.com/anyproto/anytype-ts"
SRC_URI="https://github.com/anyproto/anytype-ts/archive/refs/tags/v${PV/_alpha/-alpha}.tar.gz -> ${P/_alpha/-alpha}.tar.gz"

LICENSE="ASAL"
SLOT="0"
KEYWORDS="~amd64"

# This package requires dev-util/electron but it must be built from source (v41.x).
# It also requires a fully offline JS node_modules closure.
# Do not bypass these rules to turn CI green.
DEPEND="
	~net-misc/anytype-heart-0.51.0_rc7
	dev-vcs/git
	dev-util/electron
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/anytype-ts-${PV/_alpha/-alpha}"

# RESTRICT="network-sandbox" is removed. The ebuild must fetch all deps via SRC_URI.

src_unpack() {
	default
}

src_prepare() {
	default
}

src_compile() {
	# TODO: The npm dependency graph must be resolved and fetched offline via SRC_URI.
	# npm i --ignore-scripts || die "npm install failed"

	# TODO: Protobufs must be generated properly from the provided anytype-heart source.
	# Do not use the symlink hack.
	# mkdir -p dist/lib/pb
	# mkdir -p dist/lib/pkg
	# cp -r /usr/share/anytype-heart/pb/* dist/lib/pb/
	# cp -r /usr/share/anytype-heart/pkg/* dist/lib/pkg/
	# ln -s dist/lib middleware

	# TODO: Build electron locally.
	# node scripts/build-electron.js || die "Failed to build electron"

	# export NODE_OPTIONS=--max_old_space_size=8192
	# npm run build:deps || die "Failed to run build:deps"
	# npx vite build --config vite.config.ts || die "Failed to build vite"

	einfo "Source build blocked pending offline JS dependencies and Electron prerequisite."
}

src_install() {
	# insinto /opt/anytype
	# doins -r dist/*

	# cat << 'EOF2' > "${T}/anytype"
#!/bin/sh
# exec electron /opt/anytype "$@"
# EOF2
	# dobin "${T}/anytype"

	# make_desktop_entry "anytype" "Anytype" "anytype" "Office;Utility;"

	einfo "Source install blocked pending build step."
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
