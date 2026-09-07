# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-lang-flutter-update.yaml
EAPI=8

DESCRIPTION="Flutter makes it easy and fast to build beautiful apps"
HOMEPAGE="https://flutter.dev/"

# g2 <= 0.0.97 treats the Gentoo -rN revision as part of PV/P when parsing
# an ebuild filename, unlike Portage. Keep the upstream version explicit so
# its Manifest lint resolves the same distfile name; the update workflow
# rewrites this value when copying the packaging to a new upstream release.
UPSTREAM_PV="3.47.2"
SRC_URI="https://github.com/flutter/flutter/archive/refs/tags/${UPSTREAM_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

# Flutter requires Dart and Flutter Engine at runtime and build time for
# snapshots. However, implementing real source-built packages for these
# massive dependencies is prerequisite work that has been explicitly split
# and identified as pending. To avoid undeclared missing dependencies or
# falling back to binary packages (dev-lang/dart-bin), we omit them here.
RDEPEND="!dev-lang/flutter-bin app-arch/tar app-arch/xz-utils dev-vcs/git sys-apps/coreutils sys-apps/util-linux"
DEPEND=""

S="${WORKDIR}/flutter-${UPSTREAM_PV}"

src_prepare() {
	default

	# A distribution-managed SDK must never replace itself or rebuild its
	# package-managed tool in /opt at runtime. The prebuilt cache is
	# copied to a per-user writable cache by the launcher instead.
	sed -i 's/^\(\s\+\)\(upgrade_flutter \)/\1# \2/' "${S}/bin/internal/shared.sh" || die
}

src_compile() {
	# We intentionally skip building flutter_tools.snapshot here because
	# it requires the Dart SDK. Building the Dart SDK from source is a
	# prerequisite task that is not yet complete. The snapshot will be
	# built on-the-fly by the flutter launcher script if a system dart
	# is eventually provided, or once the prerequisite packages are
	# implemented and added to DEPEND.
	einfo "Skipping flutter_tools.snapshot compilation pending dev-lang/dart source provider."
}

src_install() {
	mkdir -p "${ED}/opt" || die
	cp -r "${S}" "${ED}/opt/flutter" || die

	# Preserve the old overlay entry point while making /usr/bin/flutter the
	# canonical launcher.
	mkdir -p "${ED}/usr/bin" || die
	dosym -r "/opt/flutter/bin/flutter" "/usr/bin/flutter"
	dosym -r "/usr/bin/flutter" "/opt/bin/flutter"
}

pkg_postinst() {
	ewarn "This genuinely source-oriented flutter package is currently blocked"
	ewarn "by massive prerequisite source packages: dev-lang/dart and"
	ewarn "dev-libs/flutter-engine. These are explicitly split tasks that"
	ewarn "must be completed before this package is fully functional."
}
