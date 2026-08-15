# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-lang-flutter-bin-update.yaml
EAPI=8

DESCRIPTION="Flutter makes it easy and fast to build beautiful apps for mobile and beyond"
HOMEPAGE="https://flutter.dev/"
SRC_URI="
	amd64? (
		https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${PV}-stable.tar.xz -> ${P}.amd64.tar.xz
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
	# executed. Flutter deliberately strips .dart_tool from release bundles after
	# warming the bundled pub cache, so recreate package_config.json from that
	# cache only before compiling the patched snapshot.
	local dart="${S}/bin/cache/dart-sdk/bin/dart"
	local tools="${S}/packages/flutter_tools"
	local snapshot="${S}/bin/cache/flutter_tools.snapshot"
	local pub_cache="${S}/.pub-cache"

	[[ -d "${pub_cache}" ]] ||
		die "Flutter installation bundle has no pre-populated pub cache"

	(
		cd "${tools}" || exit 1
		PUB_CACHE="${pub_cache}" \
			"${dart}" pub get --offline --suppress-analytics
	) || die "failed to prepare flutter_tools dependencies"

	[[ -f "${tools}/.dart_tool/package_config.json" ]] ||
		die "flutter_tools package_config.json was not generated"

	"${dart}" --verbosity=error \
		--snapshot="${snapshot}.new" \
		--snapshot-kind=app-jit \
		--packages="${tools}/.dart_tool/package_config.json" \
		--no-enable-mirrors \
		"${tools}/bin/flutter_tools.dart" || die "failed to rebuild flutter_tools.snapshot"
	mv "${snapshot}.new" "${snapshot}" || die

	# Keep the installed tree consistent with the upstream release bundle; this
	# metadata is needed only while rebuilding the snapshot.
	rm -rf "${tools}/.dart_tool" || die
}

src_install() {
	local wrapper="${T}/flutter"
	sed "s/@PV@/${PV}/g" "${FILESDIR}/${PN}-wrapper" > "${wrapper}" || die
	dobin "${wrapper}"

	mkdir "${ED}/opt" || die
	mv "${S}" "${ED}/opt/flutter" || die

	# Preserve the old overlay entry point while making /usr/bin/flutter the
	# canonical launcher.
	dosym "/usr/bin/flutter" "/opt/bin/flutter"
}
