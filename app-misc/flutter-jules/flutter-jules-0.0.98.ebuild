# Copyright 2024 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DESCRIPTION="A Flutter-based app for interacting with the Google Jules API"
HOMEPAGE="https://github.com/arran4/flutter_jules"
SRC_URI="https://github.com/arran4/flutter_jules/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="network-sandbox"
LICENSE="MIT"
SLOT="0"
S="${WORKDIR}/${PN/-/_}-${PV}"

KEYWORDS="~amd64"

RDEPEND="!app-misc/flutter-jules-bin x11-libs/gtk+:3 x11-libs/pango dev-cpp/gtkmm:3.0"
BDEPEND="dev-lang/flutter-bin dev-build/ninja dev-build/cmake virtual/pkgconfig llvm-core/clang"

src_compile() {
	flutter config --no-analytics || die
	flutter pub get || die
	flutter build linux || die
}

src_install() {
	insinto /opt/flutter_jules
	doins -r build/linux/x64/release/bundle/*
	fperms +x /opt/flutter_jules/flutter_jules
	dosym ../../opt/flutter_jules/flutter_jules /opt/bin/flutter_jules
}
