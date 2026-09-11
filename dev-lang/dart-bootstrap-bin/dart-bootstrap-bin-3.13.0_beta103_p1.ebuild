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
S="${WORKDIR}/dart-sdk"

# The SDK bundles Binaryen/LLVM/FP16, BoringSSL, ICU, Perfetto, RequireJS,
# double-conversion, and zlib in addition to Dart itself.
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT Unicode-3.0 ZLIB"
SLOT="3.13"
KEYWORDS="~amd64"
RESTRICT="strip"

BDEPEND="app-arch/unzip"

QA_PREBUILT="
	opt/${BOOTSTRAP_ROOT}/bin/dart
	opt/${BOOTSTRAP_ROOT}/bin/dartaotruntime
	opt/${BOOTSTRAP_ROOT}/bin/utils/gen_snapshot
"

src_install() {
	dodir "/opt/${BOOTSTRAP_ROOT}"
	cp -a "${S}/." "${ED}/opt/${BOOTSTRAP_ROOT}/" || die
}
