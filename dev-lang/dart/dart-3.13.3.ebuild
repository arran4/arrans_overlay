# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The Dart SDK, including the VM, dart2js, core libraries, and more."
HOMEPAGE="https://dart.dev/"
UPSTREAM_PV="3.13.3"
SRC_URI="https://github.com/dart-lang/sdk/archive/refs/tags/${UPSTREAM_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=""
DEPEND=""

S="${WORKDIR}/sdk-${UPSTREAM_PV}"

src_compile() {
	einfo "Stub build for Dart from source"
}

src_install() {
	einfo "Stub install for Dart from source"
	mkdir -p "${ED}/opt/dart-sdk/bin" || die
	touch "${ED}/opt/dart-sdk/bin/dart" || die
	chmod +x "${ED}/opt/dart-sdk/bin/dart" || die
}
