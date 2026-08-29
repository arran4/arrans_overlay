# Copyright 2024 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Cross-platform Flutter app for GGUF / llama.cpp models locally"
HOMEPAGE="https://github.com/Mobile-Artificial-Intelligence/maid"
EGIT_REPO_URI="https://github.com/Mobile-Artificial-Intelligence/maid.git"
EGIT_COMMIT="${PV}"

RESTRICT="network-sandbox"
LICENSE="MIT"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND="!app-misc/maid-appimage x11-libs/gtk+:3 x11-libs/pango dev-cpp/gtkmm:3.0"
BDEPEND="dev-lang/flutter-bin dev-build/ninja dev-build/cmake virtual/pkgconfig llvm-core/clang dev-vcs/git"

src_prepare() {
	default
}

src_compile() {
	flutter config --no-analytics || die
	flutter pub get || die
	flutter build linux || die
}

src_install() {
	insinto /opt/maid
	doins -r build/linux/x64/release/bundle/*
	fperms +x /opt/maid/maid
	dosym ../../opt/maid/maid /opt/bin/maid
}
