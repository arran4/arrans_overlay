# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd xdg desktop

DESCRIPTION="Anytype Desktop application"
HOMEPAGE="https://github.com/anyproto/anytype-ts"
SRC_URI="https://github.com/anyproto/anytype-ts/archive/refs/tags/v${PV}-alpha.tar.gz -> ${P}-alpha.tar.gz"

LICENSE="ASAL-1.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

# Needs anytype-heart and nodejs dependencies
DEPEND="
	~net-misc/anytype-heart-0.51.0_rc7
	dev-vcs/git
	dev-util/electron
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/anytype-ts-${PV}-alpha"

RESTRICT="network-sandbox"

src_unpack() {
	default
}

src_prepare() {
	default
}

src_compile() {
	npm i --ignore-scripts || die "npm install failed"

	mkdir -p dist/lib/pb
	mkdir -p dist/lib/pkg
	cp -r /usr/share/anytype-heart/pb/* dist/lib/pb/
	cp -r /usr/share/anytype-heart/pkg/* dist/lib/pkg/

	ln -s dist/lib middleware

	node scripts/build-electron.js || die "Failed to build electron"

	export NODE_OPTIONS=--max_old_space_size=8192
	npm run build:deps || die "Failed to run build:deps"
	npx vite build --config vite.config.ts || die "Failed to build vite"
}

src_install() {
	insinto /opt/anytype
	doins -r dist/*

	cat << 'EOF2' > "${T}/anytype"
#!/bin/sh
exec electron /opt/anytype "$@"
EOF2
	dobin "${T}/anytype"

	make_desktop_entry "anytype" "Anytype" "anytype" "Office;Utility;"
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
