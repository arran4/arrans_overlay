# Maintained by: .github/workflows/app-misc-flutter-jules-update.yaml
EAPI=8

inherit desktop git-r3

DESCRIPTION="Flutter desktop client for the Google Jules API"
HOMEPAGE="https://github.com/arran4/flutter_jules"
EGIT_REPO_URI="https://github.com/arran4/flutter_jules.git"
EGIT_COMMIT="0b8367fb9ffc31f42b260a5645779fd9fb92f0da"
EGIT_CHECKOUT_DIR="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Dart packages are integrity-checked by the upstream pubspec.lock, but Pub
# still needs network access to populate its build-only cache.
RESTRICT+=" network-sandbox"

COMMON_DEPEND="
	app-arch/xz-utils
	app-crypt/libsecret
	dev-libs/jsoncpp
	dev-libs/libayatana-appindicator
	media-libs/libglvnd
	sys-libs/zlib
	x11-libs/gtk+:3
	x11-libs/libX11
"
RDEPEND="
	${COMMON_DEPEND}
	!app-misc/flutter-jules-bin
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	>=dev-lang/flutter-bin-3.47.0
	app-alternatives/ninja
	dev-build/cmake
	llvm-core/clang
	virtual/pkgconfig
"

S="${EGIT_CHECKOUT_DIR}"

src_compile() {
	local build_home="${T}/home"
	local xdg_cache="${T}/xdg-cache"
	local pub_cache="${T}/pub-cache"

	mkdir -p "${build_home}" "${xdg_cache}" "${pub_cache}" || die
	export HOME="${build_home}"
	export XDG_CACHE_HOME="${xdg_cache}"
	export PUB_CACHE="${pub_cache}"
	export CI=true
	export DART_DISABLE_ANALYTICS=1

	flutter config --enable-linux-desktop || die "failed to enable Flutter Linux desktop support"
	flutter pub get --enforce-lockfile || die "failed to resolve locked Flutter dependencies"
	flutter build linux --release --no-pub || die "failed to build Flutter Jules"
}

src_install() {
	local bundle="${S}/build/linux/x64/release/bundle"

	[[ -x "${bundle}/flutter_jules" ]] || die "Flutter Jules release binary was not produced"
	[[ -f "${bundle}/lib/libapp.so" ]] || die "Flutter Jules release bundle is incomplete"
	[[ -f "${bundle}/data/icudtl.dat" ]] || die "Flutter Jules ICU data is missing"

	dodir /opt/flutter-jules
	cp -a "${bundle}/." "${ED}/opt/flutter-jules/" ||
		die "failed to install Flutter Jules release bundle"

	dosym /opt/flutter-jules/flutter_jules /usr/bin/jules_client

	insinto /usr/share/pixmaps
	newins assets/icon/app_icon.png flutter-jules.png
	make_desktop_entry jules_client "Jules Client" flutter-jules "Development;Utility;"
}
