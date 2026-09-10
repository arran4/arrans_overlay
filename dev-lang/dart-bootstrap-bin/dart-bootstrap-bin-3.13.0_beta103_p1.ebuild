# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BOOTSTRAP_VERSION="3.13.0-103.1.beta"
BOOTSTRAP_ROOT="dart-bootstrap-${BOOTSTRAP_VERSION}"
DART_ARCHIVE="https://storage.googleapis.com/dart-archive"
SDK_URI="${DART_ARCHIVE}/channels/beta/release/${BOOTSTRAP_VERSION}"

DESCRIPTION="Private bootstrap compiler for building the Dart SDK from source"
HOMEPAGE="https://dart.dev/ https://github.com/dart-lang/sdk"
SRC_URI="${SDK_URI}/sdk/dartsdk-linux-x64-release.zip -> ${P}.zip"

LICENSE="BSD"
SLOT="3.13"
KEYWORDS="~amd64"
RESTRICT="strip"

BDEPEND="app-arch/unzip"

S="${WORKDIR}/dart-sdk"

QA_PREBUILT="
	opt/${BOOTSTRAP_ROOT}/bin/dart
	opt/${BOOTSTRAP_ROOT}/bin/dartaotruntime
	opt/${BOOTSTRAP_ROOT}/bin/utils/gen_snapshot
"

src_install() {
	dodir "/opt/${BOOTSTRAP_ROOT}"
	cp -a "${S}/." "${ED}/opt/${BOOTSTRAP_ROOT}/" || die
}
