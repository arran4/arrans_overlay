# Copyright 2025 Gentoo Authors
# Distributed under the terms of the WTFPL-2 License

EAPI=8

ZIGINI_COMMIT="0bba97a12582928e097f4074cc746c43351ba4c8"
ZIG_CLAP_VER="0.9.1"

DESCRIPTION="A lightweight TUI (ncurses-like) display manager for Linux and BSD"
HOMEPAGE="https://github.com/fairyglade/ly"
SRC_URI="
	https://github.com/fairyglade/ly/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/Hejsil/zig-clap/archive/refs/tags/${ZIG_CLAP_VER}.tar.gz -> zig-clap-${ZIG_CLAP_VER}.tar.gz
	https://github.com/Kawaii-Ash/zigini/archive/${ZIGINI_COMMIT}.tar.gz -> zigini-${ZIGINI_COMMIT:0:7}.tar.gz
"

LICENSE="WTFPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

BDEPEND="|| ( dev-lang/zig-bin:0.13 dev-lang/zig:0.13 )"
RDEPEND="
	sys-libs/pam
	x11-libs/libxcb
"
DEPEND="${RDEPEND}"

src_unpack() {
	default

	# Create deps directory
	mkdir -p "${S}/deps" || die

	# Move dependencies
	mv "${WORKDIR}/zig-clap-${ZIG_CLAP_VER}" "${S}/deps/clap" || die
	mv "${WORKDIR}/zigini-${ZIGINI_COMMIT}" "${S}/deps/zigini" || die
}

src_prepare() {
	default

	# Patch build.zig.zon to use local paths
	# We use a sed command that targets the specific dependency blocks
	# Note: zig-clap block starts with .clap = .{ and zigini with .zigini = .{

	sed -i \
		-e '/\.clap = \.{/,/},/ s|\.url = ".*"|.path = "deps/clap"|' \
		-e '/\.clap = \.{/,/},/ s|\.hash = ".*"||' \
		-e '/\.zigini = \.{/,/},/ s|\.url = ".*"|.path = "deps/zigini"|' \
		-e '/\.zigini = \.{/,/},/ s|\.hash = ".*"||' \
		build.zig.zon || die "sed failed"
}

src_compile() {
	# Zig build
	# We use -Doptimize=ReleaseSafe as standard for Gentoo packages
	zig build -Doptimize=ReleaseSafe || die "zig build failed"
}

src_install() {
	# Install OpenRC service (and common files: binary, configs, pam)
	zig build installopenrc -Ddest_directory="${D}" -Doptimize=ReleaseSafe || die "installopenrc failed"

	if use systemd; then
		# Install Systemd service (re-installs common files but that's fine)
		zig build installsystemd -Ddest_directory="${D}" -Doptimize=ReleaseSafe || die "installsystemd failed"
	fi
}
