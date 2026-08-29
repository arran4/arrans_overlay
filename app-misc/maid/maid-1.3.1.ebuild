EAPI=8

DESCRIPTION="Maid is a cross-platform Flutter app for interfacing with GGUF / llama.cpp models locally."
HOMEPAGE="https://github.com/Mobile-Artificial-Intelligence/maid"

RESTRICT="network-sandbox"

# We fetch the source. Note: maid has submodules.
# For a proper Gentoo ebuild, we should fetch all submodule tarballs.
# For this PoC, we will let git fetch them during prepare if we use git,
# but it's better to fetch the tarball and initialize.
SRC_URI="https://github.com/Mobile-Artificial-Intelligence/maid/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-lang/flutter-bin"
RDEPEND="
    !app-misc/maid-appimage
    x11-libs/gtk+:3
    x11-libs/pango
    dev-cpp/gtkmm:3.0
"
BDEPEND="
    dev-build/ninja
    dev-build/cmake
    virtual/pkgconfig
    sys-devel/clang
    dev-vcs/git
"

S="${WORKDIR}/${P}"

src_prepare() {
    default
    # Initialize submodules (requires network access)
    git init || die
    git remote add origin https://github.com/Mobile-Artificial-Intelligence/maid.git || die
    git fetch origin ${PV} || die
    git reset --hard FETCH_HEAD || die
    git submodule update --init --recursive || die "Failed to init submodules"
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
