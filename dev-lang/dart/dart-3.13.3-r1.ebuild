# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Dart's upstream DEPS graph is converted to explicit Gentoo sources by
# scripts/generate_dart_ebuild.py. Do not edit the generated block manually.

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit multiprocessing python-any-r1

DESCRIPTION="The Dart SDK, including the VM, compilers, and core libraries"
HOMEPAGE="https://dart.dev/ https://github.com/dart-lang/sdk"

# BEGIN GENERATED DART DEPS
BINARYEN_REV="9926156a583cec3d22d521232b31c70fa9a87dc1"
BORINGSSL_REV="2e508c973d634b3aa51b71db5062bc6b096e5031"
CORE_REV="be0b1531c445a185d3e93887b8d0355fc766c314"
DARTDOC_REV="1d56f263955f329b6701d8f84f069eb0aef353a4"
DART_STYLE_REV="39edc2d946a5d7bd1caf6f1695f366b00f7b873c"
DEVTOOLS_SHARED_REV="12d595649f189f1896722623f72599077f476848"
ECOSYSTEM_REV="848b3bf3b757d2e9ae4d60030eeed5756c87783f"
HTTP_REV="5d94ef52582867e077bf41c3fa20fb8b1d1d834e"
I18N_REV="d0683bdea253d19a4350f5bc2be9017aba61837f"
ICU_REV="a86a32e67b8d1384b33f8fa48c83a6079b86f8cd"
LEAK_TRACKER_REV="f5620600a5ce1c44f65ddaa02001e200b096e14c"
NATIVE_REV="d51c53334486af69435b0b45c4bdfe303a830170"
PERFETTO_REV="13ce0c9e13b0940d2476cd0cff2301708a9a2e2b"
PROTOBUF_REV="84079e8b8531309e06ba7276b1c28bdca9210ad6"
PUB_REV="ec276d10a7fa0f6c6ec005340fb9ad29f3b012d0"
SHELF_REV="71248e727317930f244c4b4535e9733bcfc66677"
SYNC_HTTP_REV="6666fff944221891182e1f80bf56569338164d72"
TAR_REV="13479f7c2a18f499e840ad470cfcca8c579f6909"
TEST_REV="bd92e633e7f05edc3301865bdc00d1ae181cb1f1"
TOOLS_REV="7fec8be9af0cd0367d03dbec29b66b3f46565720"
VECTOR_MATH_REV="cf3b5db7340d317dd3489e5a35434b408020a852"
WEB_REV="eb8c3fc61a1e35f48f865836c7c7342897d91bcc"
WEBDRIVER_REV="3a711ebb36871eac997c5d5d2429f7414873dc63"
WEBKIT_PROTOCOL_REV="762115a971d1968bc940454ad1e88d506d8c5640"
ZLIB_REV="3008c4b3a06bd65392c31db8846000a21e3d03c5"

WEBKIT_GIT="https://github.com/google/webkit_inspection_protocol.dart"
ZLIB_GIT="https://github.com/gsource-mirror/chromium-src-third_party-zlib"

DEVTOOLS_SHARED_SRC="devtools-${DEVTOOLS_SHARED_REV}/packages/devtools_shared"
WEBKIT_SRC="webkit_inspection_protocol.dart-${WEBKIT_PROTOCOL_REV}"

DART_DEPENDENCY_TREES=(
	"binaryen-${BINARYEN_REV}|third_party/binaryen/src"
	"boringssl-${BORINGSSL_REV}|third_party/boringssl/src"
	"core-${CORE_REV}|third_party/pkg/core"
	"dartdoc-${DARTDOC_REV}|third_party/pkg/dartdoc"
	"dart_style-${DART_STYLE_REV}|third_party/pkg/dart_style"
	"${DEVTOOLS_SHARED_SRC}|third_party/devtools/devtools_shared"
	"ecosystem-${ECOSYSTEM_REV}|third_party/pkg/ecosystem"
	"http-${HTTP_REV}|third_party/pkg/http"
	"i18n-${I18N_REV}|third_party/pkg/i18n"
	"chromium-icu-${ICU_REV}|third_party/icu"
	"leak_tracker-${LEAK_TRACKER_REV}|third_party/pkg/leak_tracker"
	"native-${NATIVE_REV}|third_party/pkg/native"
	"perfetto-${PERFETTO_REV}|third_party/perfetto/src"
	"protobuf.dart-${PROTOBUF_REV}|third_party/pkg/protobuf"
	"pub-${PUB_REV}|third_party/pkg/pub"
	"shelf-${SHELF_REV}|third_party/pkg/shelf"
	"sync_http.dart-${SYNC_HTTP_REV}|third_party/pkg/sync_http"
	"tar-${TAR_REV}|third_party/pkg/tar"
	"test-${TEST_REV}|third_party/pkg/test"
	"tools-${TOOLS_REV}|third_party/pkg/tools"
	"vector_math.dart-${VECTOR_MATH_REV}|third_party/pkg/vector_math"
	"web-${WEB_REV}|third_party/pkg/web"
	"webdriver.dart-${WEBDRIVER_REV}|third_party/pkg/webdriver"
	"${WEBKIT_SRC}|third_party/pkg/webkit_inspection_protocol"
	"chromium-src-third_party-zlib-${ZLIB_REV}|third_party/zlib"
)

SRC_URI="
	https://github.com/dart-lang/sdk/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/WebAssembly/binaryen/archive/${BINARYEN_REV}.tar.gz
		-> dart-dep-binaryen-9926156a.tar.gz
	https://github.com/google/boringssl/archive/${BORINGSSL_REV}.tar.gz
		-> dart-dep-boringssl-2e508c97.tar.gz
	https://github.com/dart-lang/core/archive/${CORE_REV}.tar.gz
		-> dart-dep-core-be0b1531.tar.gz
	https://github.com/dart-lang/dartdoc/archive/${DARTDOC_REV}.tar.gz
		-> dart-dep-dartdoc-1d56f263.tar.gz
	https://github.com/dart-lang/dart_style/archive/${DART_STYLE_REV}.tar.gz
		-> dart-dep-dart-style-39edc2d9.tar.gz
	https://github.com/flutter/devtools/archive/${DEVTOOLS_SHARED_REV}.tar.gz
		-> dart-dep-devtools-shared-12d59564.tar.gz
	https://github.com/dart-lang/ecosystem/archive/${ECOSYSTEM_REV}.tar.gz
		-> dart-dep-ecosystem-848b3bf3.tar.gz
	https://github.com/dart-lang/http/archive/${HTTP_REV}.tar.gz
		-> dart-dep-http-5d94ef52.tar.gz
	https://github.com/dart-lang/i18n/archive/${I18N_REV}.tar.gz
		-> dart-dep-i18n-d0683bde.tar.gz
	https://github.com/librepo/chromium-icu/archive/${ICU_REV}.tar.gz
		-> dart-dep-icu-a86a32e6.tar.gz
	https://github.com/dart-lang/leak_tracker/archive/${LEAK_TRACKER_REV}.tar.gz
		-> dart-dep-leak-tracker-f5620600.tar.gz
	https://github.com/dart-lang/native/archive/${NATIVE_REV}.tar.gz
		-> dart-dep-native-d51c5333.tar.gz
	https://github.com/google/perfetto/archive/${PERFETTO_REV}.tar.gz
		-> dart-dep-perfetto-13ce0c9e.tar.gz
	https://github.com/google/protobuf.dart/archive/${PROTOBUF_REV}.tar.gz
		-> dart-dep-protobuf-84079e8b.tar.gz
	https://github.com/dart-lang/pub/archive/${PUB_REV}.tar.gz
		-> dart-dep-pub-ec276d10.tar.gz
	https://github.com/dart-lang/shelf/archive/${SHELF_REV}.tar.gz
		-> dart-dep-shelf-71248e72.tar.gz
	https://github.com/google/sync_http.dart/archive/${SYNC_HTTP_REV}.tar.gz
		-> dart-dep-sync-http-6666fff9.tar.gz
	https://github.com/simolus3/tar/archive/${TAR_REV}.tar.gz
		-> dart-dep-tar-13479f7c.tar.gz
	https://github.com/dart-lang/test/archive/${TEST_REV}.tar.gz
		-> dart-dep-test-bd92e633.tar.gz
	https://github.com/dart-lang/tools/archive/${TOOLS_REV}.tar.gz
		-> dart-dep-tools-7fec8be9.tar.gz
	https://github.com/google/vector_math.dart/archive/${VECTOR_MATH_REV}.tar.gz
		-> dart-dep-vector-math-cf3b5db7.tar.gz
	https://github.com/dart-lang/web/archive/${WEB_REV}.tar.gz
		-> dart-dep-web-eb8c3fc6.tar.gz
	https://github.com/google/webdriver.dart/archive/${WEBDRIVER_REV}.tar.gz
		-> dart-dep-webdriver-3a711ebb.tar.gz
	${WEBKIT_GIT}/archive/${WEBKIT_PROTOCOL_REV}.tar.gz
		-> dart-dep-webkit-protocol-762115a9.tar.gz
	${ZLIB_GIT}/archive/${ZLIB_REV}.tar.gz
		-> dart-dep-zlib-3008c4b3.tar.gz
"
# END GENERATED DART DEPS

# The SDK output includes Dart/double-conversion, Binaryen/LLVM/FP16,
# BoringSSL, ICU, Perfetto, RequireJS, and zlib.
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="!dev-lang/dart-bin"
BDEPEND="${PYTHON_DEPS}
	dev-build/gn
	dev-build/ninja
	dev-vcs/git
	sys-devel/gcc[cxx]
	=dev-lang/dart-bootstrap-bin-3.13.0_beta103_p1-r0:3.13
"

PATCHES=(
	"${FILESDIR}/${P}-gentoo-gcc-prefixes.patch"
	"${FILESDIR}/${P}-no-prebuilt-devtools.patch"
)

src_unpack() {
	default

	mv "sdk-${PV}" "${S}" || die

	local dependency source destination
	for dependency in "${DART_DEPENDENCY_TREES[@]}"; do
		IFS='|' read -r source destination <<< "${dependency}"
		mkdir -p "${S}/${destination%/*}" || die
		mv "${source}" "${S}/${destination}" || die
	done
}

src_prepare() {
	default
	python_setup

	# These files are normally created by gclient hooks.  Generate them with
	# the declared bootstrap compiler, forcing pub to resolve local DEPS only.
	mkdir -p build/config buildtools/ninja || die
	printf '%s\n' \
		'declare_args() {' \
		'  build_devtools_from_sources = false' \
		'}' \
		> build/config/gclient_args.gni || die
	ln -s "/opt/dart-bootstrap-3.13.0-103.1.beta" \
		tools/sdks/dart-sdk || die
	_PUB_TEST_SDK_VERSION=${PV} tools/sdks/dart-sdk/bin/dart \
		pub get --offline || die
	"${EPYTHON}" tools/generate_sdk_version_file.py || die

	ln -s "${BROOT}/usr/bin/gn" buildtools/gn || die
	ln -s "${BROOT}/usr/bin/ninja" buildtools/ninja/ninja || die
}

src_compile() {
	# --no-clang selects the native system toolchain and, consequently, no
	# downloaded Dart sysroot.  This package intentionally supports native
	# amd64 builds only.
	./tools/build.py \
		--arch x64 \
		--mode release \
		--no-clang \
		--no-git-version \
		--no-verify-sdk-hash \
		--toolchain-prefix "x64=${CHOST}-" \
		-j "$(makeopts_jobs)" \
		create_sdk || die
}

src_install() {
	dodir /opt/dart-sdk
	cp -a out/ReleaseX64/dart-sdk/. "${ED}/opt/dart-sdk/" || die
	dosym ../dart-sdk/bin/dart /opt/bin/dart
}
