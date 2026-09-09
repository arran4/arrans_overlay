# Copyright 2024-2026 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The Flutter Engine: C++ core of Flutter"
HOMEPAGE="https://github.com/flutter/engine"

# Flutter 3.47.2 requires engine commit a804b261645ef8c13eb3d5c44a5c2fb0340c5539
# Note: Building Flutter Engine natively requires depot_tools/gclient resolution
# to be performed offline, and blocking on Dart being built from source.

SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="network-sandbox"

# Dependency order and blockers:
# 1. dev-lang/dart (#907) must be packaged from source. Flutter Engine needs to
#    either depend on this package or we need to extract its DEPS and build the
#    pinned Dart revision concurrently.
# 2. depot_tools/gclient is required to fetch dependencies natively, but Portage
#    builds must be offline. We must translate the Engine's DEPS file into a
#    massive SRC_URI list or provide a pre-rolled tarball of dependencies (like
#    Chromium does). This includes Skia, Impeller, and Chromium-base dependencies.
# 3. Missing packaging for GN build rules that are usually fetched via gclient.

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="
	dev-vcs/git
	dev-build/ninja
	dev-build/gn
"

S="${WORKDIR}/engine-${PV}"

src_unpack() {
	default
}

src_prepare() {
	default
}

src_configure() {
	einfo "Configuring Flutter Engine"
}

src_compile() {
	einfo "Compiling Flutter Engine"
}

src_install() {
	einfo "Installing Flutter Engine"
}
