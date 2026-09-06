# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-lang-flutter-update.yaml
EAPI=8

DESCRIPTION="Flutter makes it easy and fast to build beautiful apps for mobile and beyond"
HOMEPAGE="https://flutter.dev/"

# g2 <= 0.0.97 treats the Gentoo -rN revision as part of PV/P when parsing an
# ebuild filename, unlike Portage. Keep the upstream version explicit so its
# Manifest lint resolves the same distfile name; the update workflow rewrites
# this value when copying the packaging to a new upstream Flutter release.
UPSTREAM_PV="3.47.2"
SRC_URI="https://github.com/flutter/flutter/archive/refs/tags/${UPSTREAM_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="network-sandbox"

RDEPEND="app-arch/tar app-arch/xz-utils dev-vcs/git sys-apps/coreutils sys-apps/util-linux"
DEPEND="dev-lang/dart-bin"

S="${WORKDIR}/flutter-${UPSTREAM_PV}"

PATCHES=(
	"${FILESDIR}/${PN}-xdg-cache.patch"
)

src_prepare() {
	default

	# A distribution-managed SDK must never replace itself or rebuild its
	# package-managed tool in /opt at runtime. The prebuilt cache is copied to a
	# per-user writable cache by the launcher instead.
	sed -i 's/^\(\s\+\)\(upgrade_flutter \)/\1# \2/' "${S}/bin/internal/shared.sh" || die

	# We need to make it use system dart
	sed -i 's#DART_SDK_PATH="$FLUTTER_CACHE_DIR/dart-sdk"#DART_SDK_PATH="/opt/dart-sdk"#' "${S}/bin/internal/shared.sh" || die
	sed -i 's#cacheRoot, "dart-sdk"#"/opt/dart-sdk"#' "${S}/packages/flutter_tools/lib/src/dart/pub.dart" || true
}

src_compile() {
	# flutter_tools.snapshot is supplied precompiled in the release archive. Our
	# Dart-side cache patch therefore needs a new snapshot or it would never be
	# executed. Flutter strips .dart_tool from release bundles and ships the pub
	# packages as .pub-preload-cache/*.tar.gz. Expand those archives into a
	# package-managed pub cache and retain the generated flutter_tools package
	# configuration so Flutter never needs to repair its own SDK at runtime.
	local dart="/opt/dart-sdk/bin/dart"
	local tools="${S}/packages/flutter_tools"
	local snapshot="${S}/bin/cache/flutter_tools.snapshot"
	local pub_cache="${S}/.pub-cache"
	local package_config="${tools}/.dart_tool/package_config.json"
	local build_home="${T}/home"

	mkdir -p "${pub_cache}" "${build_home}" "${S}/bin/cache" || die

	(
		cd "${tools}" || return 1
		HOME="${build_home}" PUB_CACHE="${pub_cache}" \
			"${dart}" pub --suppress-analytics get
	) || die "failed to prepare flutter_tools dependencies"

	[[ -f "${package_config}" ]] ||
		die "flutter_tools package_config.json was not generated"

	"${dart}" --verbosity=error \
		--snapshot="${snapshot}.new" \
		--snapshot-kind=app-jit \
		--packages="${package_config}" \
		--no-enable-mirrors \
		"${tools}/bin/flutter_tools.dart" || die "failed to rebuild flutter_tools.snapshot"
	mv "${snapshot}.new" "${snapshot}" || die

	# Pub records absolute paths for packages in an absolute PUB_CACHE. The SDK
	# tree is moved from the Portage work directory to /opt/flutter at install
	# time, so relocate the retained immutable tool package configuration only
	# after the snapshot has been compiled against its build-time paths.
	grep -Fq "${S}" "${package_config}" ||
		die "flutter_tools package config contains no relocatable build-root paths"
	sed -i "s#${S}#/opt/flutter#g" "${package_config}" ||
		die "failed to relocate flutter_tools package config"
	if grep -Fq "${S}" "${package_config}"; then
		die "flutter_tools package config still references the Portage build root"
	fi

	# We also need to fetch flutter engine components
	HOME="${build_home}" PUB_CACHE="${pub_cache}" "${S}/bin/flutter" precache || die "failed to precache flutter engine"
}

src_install() {
	local wrapper="${T}/flutter"
	sed \
		-e "s/@PV@/${PV}/g" \
		-e "s/@PVR@/${PVR}/g" \
		"${FILESDIR}/${PN}-wrapper" > "${wrapper}" || die
	dobin "${wrapper}"

	mkdir "${ED}/opt" || die
	mv "${S}" "${ED}/opt/flutter" || die

	# Preserve the old overlay entry point while making /usr/bin/flutter the
	# canonical launcher.
	dosym "../../opt/bin/flutter" "/usr/bin/flutter"
}
