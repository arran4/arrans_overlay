EAPI=8

DESCRIPTION="A comprehensive Flutter-based client application for interacting with the Google Jules API."
HOMEPAGE="https://github.com/arran4/flutter_jules"

# Flutter apps require fetching dependencies at build time if not pre-cached,
# which is generally discouraged in Gentoo without a proper offline cache.
# However, as a proof of concept/overlay package, we will allow network access.
RESTRICT="network-sandbox"

SRC_URI="https://github.com/arran4/flutter_jules/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-lang/flutter-bin"
RDEPEND="
    !app-misc/flutter-jules-bin
    x11-libs/gtk+:3
    x11-libs/pango
    dev-cpp/gtkmm:3.0
"
BDEPEND="
    dev-build/ninja
    dev-build/cmake
    virtual/pkgconfig
    sys-devel/clang
"

S="${WORKDIR}/${PN}-${PV}"

src_compile() {
    # Disable telemetry during build
    flutter config --no-analytics || die "Failed to disable flutter analytics"

    # Fetch flutter dependencies
    flutter pub get || die "flutter pub get failed"

    # Build for Linux
    flutter build linux || die "flutter build linux failed"
}

src_install() {

    # The build output is typically in build/linux/x64/release/bundle/
    # For now, let's copy the bundle to /opt/flutter_jules and symlink the executable
    insinto /opt/flutter_jules
    doins -r build/linux/x64/release/bundle/*

    fperms +x /opt/flutter_jules/flutter_jules
    dosym ../../opt/flutter_jules/flutter_jules /opt/bin/flutter_jules
}
