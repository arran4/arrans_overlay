# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-lang-flutter-bin-update.yaml
EAPI=8

DESCRIPTION="Flutter makes it easy and fast to build beautiful apps for mobile and beyond"
HOMEPAGE="https://flutter.dev/"

# g2 <= 0.0.97 treats the Gentoo -rN revision as part of PV/P when parsing an
# ebuild filename, unlike Portage. Keep the upstream version explicit so its
# Manifest lint resolves the same distfile name; the update workflow rewrites
# this value when copying the packaging to a new upstream Flutter release.
UPSTREAM_PV="3.47.0"
SRC_URI="
	amd64? (
		https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${UPSTREAM_PV}-stable.tar.xz -> ${PN}-${UPSTREAM_PV}.amd64.tar.xz
	)
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-arch/tar
	app-arch/xz-utils
	dev-vcs/git
	sys-apps/coreutils
	sys-apps/util-linux
"

S="${WORKDIR}/flutter"

PATCHES=(
	"${FILESDIR}/${PN}-xdg-cache.patch"
)

src_prepare() {
	default

	# A distribution-managed SDK must never replace itself or rebuild its
	# package-managed tool in /opt at runtime. The prebuilt cache is copied to a
	# per-user writable cache by the launcher instead.
	sed -i 's/^\(\s\+\)\(upgrade_flutter \)/\1# \2/' "${S}/bin/internal/shared.sh" || die
}

src_compile() {
	# flutter_tools.snapshot is supplied precompiled in the release archive. Our
	# Dart-side cache patch therefore needs a new snapshot or it would never be
	# executed. Flutter strips .dart_tool from release bundles and ships the pub
	# packages as .pub-preload-cache/*.tar.gz. Expand those archives into a
	# package-managed pub cache and retain the generated flutter_tools package
	# configuration so Flutter never needs to repair its own SDK at runtime.
	local dart="${S}/bin/cache/dart-sdk/bin/dart"
	local tools="${S}/packages/flutter_tools"
	local snapshot="${S}/bin/cache/flutter_tools.snapshot"
	local preload_cache="${S}/.pub-preload-cache"
	local pub_cache="${S}/.pub-cache"
	local package_config="${tools}/.dart_tool/package_config.json"
	local build_home="${T}/home"
	local preload_archive

	[[ -d "${preload_cache}" ]] ||
		die "Flutter installation bundle has no pub preload cache"
	preload_archive=$(find "${preload_cache}" -maxdepth 1 -type f -name '*.tar.gz' -print -quit) || die
	[[ -n "${preload_archive}" ]] ||
		die "Flutter installation bundle has no preloaded pub archives"
	mkdir -p "${pub_cache}" "${build_home}" || die

	HOME="${build_home}" PUB_CACHE="${pub_cache}" \
		"${dart}" pub --suppress-analytics cache preload "${preload_cache}"/*.tar.gz ||
		die "failed to preload bundled pub packages"

	(
		cd "${tools}" || exit 1
		HOME="${build_home}" PUB_CACHE="${pub_cache}" \
			"${dart}" pub --suppress-analytics get --offline
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

	# The compressed preload cache has now served its purpose. Keeping only the
	# expanded package-managed seed avoids storing every dependency twice. The
	# launcher copies this seed into each user's PUB_CACHE on first use.
	rm -rf "${preload_cache}" || die
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
	dosym "/usr/bin/flutter" "/opt/bin/flutter"
}
