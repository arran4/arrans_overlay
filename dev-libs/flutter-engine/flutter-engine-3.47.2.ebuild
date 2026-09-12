# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Flutter Engine's upstream DEPS graph is converted to explicit Gentoo sources
# by scripts/generate_flutter_engine_ebuild.py. Do not edit the generated block.

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit multiprocessing ninja-utils python-any-r1 toolchain-funcs

DESCRIPTION="The runtime engine for Flutter applications"
HOMEPAGE="https://flutter.dev/ https://github.com/flutter/flutter"

FLUTTER_ENGINE_REV="a804b261645ef8c13eb3d5c44a5c2fb0340c5539"

# BEGIN GENERATED FLUTTER ENGINE DEPS
ABSEIL_CPP_REV="564023aa53767b5f60b3a556f0a025b7b7e8241e"
BORINGSSL_REV="2e508c973d634b3aa51b71db5062bc6b096e5031"
BROTLI_REV="350100a5bb9d9671aca85213b2ec7a70a361b0cd"
DARTDOC_REV="1d56f263955f329b6701d8f84f069eb0aef353a4"
DART_BINARYEN_REV="9926156a583cec3d22d521232b31c70fa9a87dc1"
DART_CORE_REV="be0b1531c445a185d3e93887b8d0355fc766c314"
DART_ECOSYSTEM_REV="848b3bf3b757d2e9ae4d60030eeed5756c87783f"
DART_HTTP_REV="5d94ef52582867e077bf41c3fa20fb8b1d1d834e"
DART_I18N_REV="d0683bdea253d19a4350f5bc2be9017aba61837f"
DART_LEAK_TRACKER_REV="f5620600a5ce1c44f65ddaa02001e200b096e14c"
DART_NATIVE_REV="81e464e7ff06aa66246b38a326025e3dba6928d3"
DART_PERFETTO_REV="13ce0c9e13b0940d2476cd0cff2301708a9a2e2b"
DART_PROTOBUF_REV="84079e8b8531309e06ba7276b1c28bdca9210ad6"
DART_PUB_REV="ec276d10a7fa0f6c6ec005340fb9ad29f3b012d0"
DART_SHELF_REV="71248e727317930f244c4b4535e9733bcfc66677"
DART_STYLE_REV="39edc2d946a5d7bd1caf6f1695f366b00f7b873c"
DART_SYNC_HTTP_REV="6666fff944221891182e1f80bf56569338164d72"
DART_TAR_REV="13479f7c2a18f499e840ad470cfcca8c579f6909"
DART_TEST_REV="bd92e633e7f05edc3301865bdc00d1ae181cb1f1"
DART_TOOLS_REV="7fec8be9af0cd0367d03dbec29b66b3f46565720"
DART_VECTOR_MATH_REV="cf3b5db7340d317dd3489e5a35434b408020a852"
DART_WEB_REV="eb8c3fc61a1e35f48f865836c7c7342897d91bcc"
DART_WEBDRIVER_REV="3a711ebb36871eac997c5d5d2429f7414873dc63"
DART_WEBKIT_PROTOCOL_REV="762115a971d1968bc940454ad1e88d506d8c5640"
DEVTOOLS_SHARED_REV="12d595649f189f1896722623f72599077f476848"
EXPAT_REV="8e49998f003d693213b538ef765814c7d21abada"
FLATBUFFERS_REV="067bfdbde9b10c1beb5d6b02d67ae9db8b96f736"
HARFBUZZ_REV="49844c32a7a3f6be371355a1213c952a3f4a44e7"
ICU_REV="a86a32e67b8d1384b33f8fa48c83a6079b86f8cd"
LIBWEBP_REV="ca332209cb5567c9b249c86788cb2dbf8847e760"
SDK_REV="60a57cd42d64dc03e9f07aa60a2e250755c1ef28"
SHADERC_REV="d15277d6bc180f6a0b8b601f0cab2bbcaac9b4d5"
SKIA_REV="8df24be66531469e576a806749a0202ae26b8d08"
SWIFTSHADER_REV="794b0cfce1d828d187637e6d932bae484fbe0976"
VK_GLSLANG_REV="a57276bf558f5cf94d3a9854ebdf5a2236849a5a"
VK_HEADERS_REV="a4f8ada9f4f97c45b8c89c57997be9cebaae65d2"
VK_LOADER_REV="f703f919c30c5b67958d35d40a4297cb3823ed78"
VK_LUNARG_VULKANTOOLS_REV="b9afdd8c070500c375e95acf33c79f0420d59b17"
VK_SPIRV_CROSS_REV="b8fcf307f1f347089e3c46eb4451d27f32ebc8d3"
VK_SPIRV_HEADERS_REV="01e0577914a75a2569c846778c2f93aa8e6feddd"
VK_SPIRV_TOOLS_REV="19042c8921f35f7bec56b9e5c96c5f5691588ca8"
VK_TOOLS_REV="d643b80d6ba8c191bc289fdda52867c3bb3c190b"
VK_UTILITY_LIBRARIES_REV="4322db5906e67b57ec9c327e6afe3d98ed893df7"
VK_VALIDATION_LAYERS_REV="951aec1ecf22dc84a99a5c8bec9223c5810cc3e1"
WUFFS_REV="600cd96cf47788ee3a74b40a6028b035c9fd6a61"
ZLIB_REV="7eda07b1e067ef3fd7eea0419c88b5af45c9a776"

BINARYEN_GIT="https://github.com/WebAssembly/binaryen"
DEVTOOLS_GIT="https://github.com/flutter/devtools"
ECOSYSTEM_GIT="https://github.com/dart-lang/ecosystem"
KH_GLSLANG_GIT="https://github.com/KhronosGroup/glslang"
KH_SPIRV_CROSS_GIT="https://github.com/KhronosGroup/SPIRV-Cross"
KH_SPIRV_HEADERS_GIT="https://github.com/KhronosGroup/SPIRV-Headers"
KH_SPIRV_TOOLS_GIT="https://github.com/KhronosGroup/SPIRV-Tools"
KH_VK_HEADERS_GIT="https://github.com/KhronosGroup/Vulkan-Headers"
KH_VK_LAYERS_GIT="https://github.com/KhronosGroup/Vulkan-ValidationLayers"
KH_VK_LOADER_GIT="https://github.com/KhronosGroup/Vulkan-Loader"
KH_VK_TOOLS_GIT="https://github.com/KhronosGroup/Vulkan-Tools"
KH_VK_UTIL_GIT="https://github.com/KhronosGroup/Vulkan-Utility-Libraries"
LEAK_TRACKER_GIT="https://github.com/dart-lang/leak_tracker"
LUNARG_VK_TOOLS_GIT="https://github.com/LunarG/VulkanTools"
PROTOBUF_GIT="https://github.com/google/protobuf.dart"
SYNC_HTTP_GIT="https://github.com/google/sync_http.dart"
VECTOR_MATH_GIT="https://github.com/google/vector_math.dart"
WEBDRIVER_GIT="https://github.com/google/webdriver.dart"
WEBKIT_GIT="https://github.com/google/webkit_inspection_protocol.dart"
WUFFS_GIT="https://github.com/google/wuffs-mirror-release-c"
ZLIB_GIT="https://github.com/gsource-mirror/chromium-src-third_party-zlib"

DART_PKG_DIR="flutter/third_party/dart/third_party/pkg"
DART_TP_DIR="flutter/third_party/dart/third_party"
VK_DEPS_DIR="flutter/third_party/vulkan-deps"

DART_WEBKIT_SRC="webkit_inspection_protocol.dart-${DART_WEBKIT_PROTOCOL_REV}"
DEVTOOLS_SHARED_SRC="devtools-${DEVTOOLS_SHARED_REV}/packages/devtools_shared"
VK_LUNARG_SRC="VulkanTools-${VK_LUNARG_VULKANTOOLS_REV}"
VK_UTIL_SRC="Vulkan-Utility-Libraries-${VK_UTILITY_LIBRARIES_REV}"
VK_VALIDATION_SRC="Vulkan-ValidationLayers-${VK_VALIDATION_LAYERS_REV}"

FLUTTER_ENGINE_DEPENDENCY_TREES=(
	"abseil-cpp-${ABSEIL_CPP_REV}|third_party/abseil-cpp"
	"brotli-${BROTLI_REV}|flutter/third_party/brotli"
	"sdk-${SDK_REV}|flutter/third_party/dart"
	"libexpat-${EXPAT_REV}|flutter/third_party/expat"
	"flatbuffers-${FLATBUFFERS_REV}|flutter/third_party/flatbuffers"
	"harfbuzz-${HARFBUZZ_REV}|flutter/third_party/harfbuzz"
	"chromium-icu-${ICU_REV}|flutter/third_party/icu"
	"libwebp-${LIBWEBP_REV}|flutter/third_party/libwebp"
	"shaderc-${SHADERC_REV}|flutter/third_party/shaderc"
	"skia-${SKIA_REV}|flutter/third_party/skia"
	"swiftshader-${SWIFTSHADER_REV}|flutter/third_party/swiftshader"
	"wuffs-mirror-release-c-${WUFFS_REV}|flutter/third_party/wuffs"
	"chromium-src-third_party-zlib-${ZLIB_REV}|flutter/third_party/zlib"
	"boringssl-${BORINGSSL_REV}|flutter/third_party/boringssl/src"
	"glslang-${VK_GLSLANG_REV}|${VK_DEPS_DIR}/glslang/src"
	"${VK_LUNARG_SRC}|${VK_DEPS_DIR}/lunarg-vulkantools/src"
	"SPIRV-Cross-${VK_SPIRV_CROSS_REV}|${VK_DEPS_DIR}/spirv-cross/src"
	"SPIRV-Headers-${VK_SPIRV_HEADERS_REV}|${VK_DEPS_DIR}/spirv-headers/src"
	"SPIRV-Tools-${VK_SPIRV_TOOLS_REV}|${VK_DEPS_DIR}/spirv-tools/src"
	"Vulkan-Headers-${VK_HEADERS_REV}|${VK_DEPS_DIR}/vulkan-headers/src"
	"Vulkan-Loader-${VK_LOADER_REV}|${VK_DEPS_DIR}/vulkan-loader/src"
	"Vulkan-Tools-${VK_TOOLS_REV}|${VK_DEPS_DIR}/vulkan-tools/src"
	"${VK_UTIL_SRC}|${VK_DEPS_DIR}/vulkan-utility-libraries/src"
	"${VK_VALIDATION_SRC}|${VK_DEPS_DIR}/vulkan-validation-layers/src"
	"binaryen-${DART_BINARYEN_REV}|${DART_TP_DIR}/binaryen/src"
	"${DEVTOOLS_SHARED_SRC}|${DART_TP_DIR}/devtools/devtools_shared"
	"perfetto-${DART_PERFETTO_REV}|${DART_TP_DIR}/perfetto/src"
	"core-${DART_CORE_REV}|${DART_PKG_DIR}/core"
	"dart_style-${DART_STYLE_REV}|${DART_PKG_DIR}/dart_style"
	"dartdoc-${DARTDOC_REV}|${DART_PKG_DIR}/dartdoc"
	"ecosystem-${DART_ECOSYSTEM_REV}|${DART_PKG_DIR}/ecosystem"
	"http-${DART_HTTP_REV}|${DART_PKG_DIR}/http"
	"i18n-${DART_I18N_REV}|${DART_PKG_DIR}/i18n"
	"leak_tracker-${DART_LEAK_TRACKER_REV}|${DART_PKG_DIR}/leak_tracker"
	"native-${DART_NATIVE_REV}|${DART_PKG_DIR}/native"
	"protobuf.dart-${DART_PROTOBUF_REV}|${DART_PKG_DIR}/protobuf"
	"pub-${DART_PUB_REV}|${DART_PKG_DIR}/pub"
	"shelf-${DART_SHELF_REV}|${DART_PKG_DIR}/shelf"
	"sync_http.dart-${DART_SYNC_HTTP_REV}|${DART_PKG_DIR}/sync_http"
	"tar-${DART_TAR_REV}|${DART_PKG_DIR}/tar"
	"test-${DART_TEST_REV}|${DART_PKG_DIR}/test"
	"tools-${DART_TOOLS_REV}|${DART_PKG_DIR}/tools"
	"vector_math.dart-${DART_VECTOR_MATH_REV}|${DART_PKG_DIR}/vector_math"
	"web-${DART_WEB_REV}|${DART_PKG_DIR}/web"
	"webdriver.dart-${DART_WEBDRIVER_REV}|${DART_PKG_DIR}/webdriver"
	"${DART_WEBKIT_SRC}|${DART_PKG_DIR}/webkit_inspection_protocol"
)

SRC_URI="
	https://github.com/flutter/flutter/archive/${FLUTTER_ENGINE_REV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/abseil/abseil-cpp/archive/${ABSEIL_CPP_REV}.tar.gz
		-> flutter-dep-abseil-cpp-564023aa.tar.gz
	https://github.com/google/boringssl/archive/${BORINGSSL_REV}.tar.gz
		-> dart-dep-boringssl-2e508c97.tar.gz
	https://github.com/google/brotli/archive/${BROTLI_REV}.tar.gz
		-> flutter-dep-brotli-350100a5.tar.gz
	https://github.com/dart-lang/dartdoc/archive/${DARTDOC_REV}.tar.gz
		-> flutter-dep-dartdoc-1d56f263.tar.gz
	${BINARYEN_GIT}/archive/${DART_BINARYEN_REV}.tar.gz
		-> dart-dep-dart-binaryen-9926156a.tar.gz
	https://github.com/dart-lang/core/archive/${DART_CORE_REV}.tar.gz
		-> dart-dep-dart-core-be0b1531.tar.gz
	${ECOSYSTEM_GIT}/archive/${DART_ECOSYSTEM_REV}.tar.gz
		-> dart-dep-dart-ecosystem-848b3bf3.tar.gz
	https://github.com/dart-lang/http/archive/${DART_HTTP_REV}.tar.gz
		-> dart-dep-dart-http-5d94ef52.tar.gz
	https://github.com/dart-lang/i18n/archive/${DART_I18N_REV}.tar.gz
		-> dart-dep-dart-i18n-d0683bde.tar.gz
	${LEAK_TRACKER_GIT}/archive/${DART_LEAK_TRACKER_REV}.tar.gz
		-> dart-dep-dart-leak-tracker-f5620600.tar.gz
	https://github.com/dart-lang/native/archive/${DART_NATIVE_REV}.tar.gz
		-> dart-dep-dart-native-81e464e7.tar.gz
	https://github.com/google/perfetto/archive/${DART_PERFETTO_REV}.tar.gz
		-> dart-dep-dart-perfetto-13ce0c9e.tar.gz
	${PROTOBUF_GIT}/archive/${DART_PROTOBUF_REV}.tar.gz
		-> dart-dep-dart-protobuf-84079e8b.tar.gz
	https://github.com/dart-lang/pub/archive/${DART_PUB_REV}.tar.gz
		-> dart-dep-dart-pub-ec276d10.tar.gz
	https://github.com/dart-lang/shelf/archive/${DART_SHELF_REV}.tar.gz
		-> dart-dep-dart-shelf-71248e72.tar.gz
	https://github.com/dart-lang/dart_style/archive/${DART_STYLE_REV}.tar.gz
		-> dart-dep-dart-style-39edc2d9.tar.gz
	${SYNC_HTTP_GIT}/archive/${DART_SYNC_HTTP_REV}.tar.gz
		-> dart-dep-dart-sync-http-6666fff9.tar.gz
	https://github.com/simolus3/tar/archive/${DART_TAR_REV}.tar.gz
		-> dart-dep-dart-tar-13479f7c.tar.gz
	https://github.com/dart-lang/test/archive/${DART_TEST_REV}.tar.gz
		-> dart-dep-dart-test-bd92e633.tar.gz
	https://github.com/dart-lang/tools/archive/${DART_TOOLS_REV}.tar.gz
		-> dart-dep-dart-tools-7fec8be9.tar.gz
	${VECTOR_MATH_GIT}/archive/${DART_VECTOR_MATH_REV}.tar.gz
		-> dart-dep-dart-vector-math-cf3b5db7.tar.gz
	https://github.com/dart-lang/web/archive/${DART_WEB_REV}.tar.gz
		-> dart-dep-dart-web-eb8c3fc6.tar.gz
	${WEBDRIVER_GIT}/archive/${DART_WEBDRIVER_REV}.tar.gz
		-> dart-dep-dart-webdriver-3a711ebb.tar.gz
	${WEBKIT_GIT}/archive/${DART_WEBKIT_PROTOCOL_REV}.tar.gz
		-> dart-dep-dart-webkit-protocol-762115a9.tar.gz
	${DEVTOOLS_GIT}/archive/${DEVTOOLS_SHARED_REV}.tar.gz
		-> dart-dep-devtools-shared-12d59564.tar.gz
	https://github.com/libexpat/libexpat/archive/${EXPAT_REV}.tar.gz
		-> flutter-dep-expat-8e49998f.tar.gz
	https://github.com/google/flatbuffers/archive/${FLATBUFFERS_REV}.tar.gz
		-> flutter-dep-flatbuffers-067bfdbd.tar.gz
	https://github.com/harfbuzz/harfbuzz/archive/${HARFBUZZ_REV}.tar.gz
		-> flutter-dep-harfbuzz-49844c32.tar.gz
	https://github.com/librepo/chromium-icu/archive/${ICU_REV}.tar.gz
		-> dart-dep-icu-a86a32e6.tar.gz
	https://github.com/webmproject/libwebp/archive/${LIBWEBP_REV}.tar.gz
		-> flutter-dep-libwebp-ca332209.tar.gz
	https://github.com/dart-lang/sdk/archive/${SDK_REV}.tar.gz
		-> flutter-dep-sdk-60a57cd4.tar.gz
	https://github.com/google/shaderc/archive/${SHADERC_REV}.tar.gz
		-> flutter-dep-shaderc-d15277d6.tar.gz
	https://github.com/google/skia/archive/${SKIA_REV}.tar.gz
		-> flutter-dep-skia-8df24be6.tar.gz
	https://github.com/google/swiftshader/archive/${SWIFTSHADER_REV}.tar.gz
		-> flutter-dep-swiftshader-794b0cfc.tar.gz
	${KH_GLSLANG_GIT}/archive/${VK_GLSLANG_REV}.tar.gz
		-> flutter-dep-vk-glslang-a57276bf.tar.gz
	${KH_VK_HEADERS_GIT}/archive/${VK_HEADERS_REV}.tar.gz
		-> flutter-dep-vk-headers-a4f8ada9.tar.gz
	${KH_VK_LOADER_GIT}/archive/${VK_LOADER_REV}.tar.gz
		-> flutter-dep-vk-loader-f703f919.tar.gz
	${LUNARG_VK_TOOLS_GIT}/archive/${VK_LUNARG_VULKANTOOLS_REV}.tar.gz
		-> flutter-dep-vk-lunarg-vulkantools-b9afdd8c.tar.gz
	${KH_SPIRV_CROSS_GIT}/archive/${VK_SPIRV_CROSS_REV}.tar.gz
		-> flutter-dep-vk-spirv-cross-b8fcf307.tar.gz
	${KH_SPIRV_HEADERS_GIT}/archive/${VK_SPIRV_HEADERS_REV}.tar.gz
		-> flutter-dep-vk-spirv-headers-01e05779.tar.gz
	${KH_SPIRV_TOOLS_GIT}/archive/${VK_SPIRV_TOOLS_REV}.tar.gz
		-> flutter-dep-vk-spirv-tools-19042c89.tar.gz
	${KH_VK_TOOLS_GIT}/archive/${VK_TOOLS_REV}.tar.gz
		-> flutter-dep-vk-tools-d643b80d.tar.gz
	${KH_VK_UTIL_GIT}/archive/${VK_UTILITY_LIBRARIES_REV}.tar.gz
		-> flutter-dep-vk-utility-libraries-4322db59.tar.gz
	${KH_VK_LAYERS_GIT}/archive/${VK_VALIDATION_LAYERS_REV}.tar.gz
		-> flutter-dep-vk-validation-layers-951aec1e.tar.gz
	${WUFFS_GIT}/archive/${WUFFS_REV}.tar.gz
		-> flutter-dep-wuffs-600cd96c.tar.gz
	${ZLIB_GIT}/archive/${ZLIB_REV}.tar.gz
		-> dart-dep-zlib-7eda07b1.tar.gz
"
# END GENERATED FLUTTER ENGINE DEPS

LICENSE="Apache-2.0 BSD FTL GPL-2+ IJG libpng MIT openssl Unicode-DFS-2016 ZLIB"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	dev-libs/glib:2
	games-util/libtess2
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd
	media-libs/libjpeg-turbo
	media-libs/libpng
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/pango
"
DEPEND="
	${RDEPEND}
	dev-util/vulkan-headers
	media-libs/vulkan-loader
"
BDEPEND="
	${PYTHON_DEPS}
	dev-build/gn
	dev-build/ninja
	dev-python/pyyaml
	virtual/dart
"

PATCHES=(
	"${FILESDIR}/flutter-engine-${PV}-gn-version-fallback.patch"
	"${FILESDIR}/flutter-engine-${PV}-compiler-version-python3.patch"
	"${FILESDIR}/flutter-engine-${PV}-system-libraries.patch"
)

FLUTTER_ENGINE_DIR="/usr/lib/flutter-engine/${PV}"
FLUTTER_ENGINE_ARCH_DIR="${FLUTTER_ENGINE_DIR}/linux-x64"

S="${WORKDIR}/flutter-${FLUTTER_ENGINE_REV}/engine/src"

src_unpack() {
	default

	for dep in "${FLUTTER_ENGINE_DEPENDENCY_TREES[@]}"; do
		local src="${WORKDIR}/${dep%%|*}"
		local dest="${S}/${dep##*|}"
		mkdir -p "$(dirname "${dest}")" || die
		mv "${src}" "${dest}" || die
	done
}

src_prepare() {
	default

	sed -i 's/"vpython3"/"python3"/' .gn || die

	# Build and toolchain helpers expect buildtools to exist.
	mkdir -p flutter/third_party/gn || die
	ln -sf "${BROOT}/usr/bin/gn" flutter/third_party/gn/gn || die

	# Compatibility symlink for unbundled libtess2 header.
	mkdir -p third_party/libtess2/Include || die
	ln -sf "${ESYSROOT}/usr/include/tesselator.h" \
		third_party/libtess2/Include/tesselator.h || die

	# Dart inside Flutter engine requires devtools_from_sources disabled
	# and the host Dart SDK linked for offline pub package resolution.
	mkdir -p flutter/third_party/dart/build/config || die
	printf '%s\n' \
		'declare_args() {' \
		'  build_devtools_from_sources = false' \
		'}' \
		> flutter/third_party/dart/build/config/gclient_args.gni || die

	local host_dart
	host_dart=$(readlink -f "$(type -P dart)") || die
	local host_dart_sdk
	host_dart_sdk="$(dirname "$(dirname "${host_dart}")")"
	local dart_sdks_dir="flutter/third_party/dart/tools/sdks"
	mkdir -p "${dart_sdks_dir}" || die
	ln -sf "${host_dart_sdk}" "${dart_sdks_dir}/dart-sdk" || die

	pushd flutter/third_party/dart >/dev/null || die
	dart pub get --offline || die
	popd >/dev/null || die
}

src_configure() {
	tc-export AR CC CXX NM RANLIB

	local gn_args=(
		--no-goma
		--no-rbe
		--runtime-mode=release
		--no-prebuilt-dart
		--no-build-embedder-examples
		--no-default-linux-sysroot
		--no-enable-unittests
		--no-clang
	)

	python3 flutter/tools/gn "${gn_args[@]}" || die "GN configure failed"
}

src_compile() {
	local ninja_targets=(
		flutter/shell/platform/linux:flutter_gtk
		flutter/third_party/dart/runtime/bin:gen_snapshot
		flutter/shell/testing:flutter_tester
		flutter/impeller/compiler:impellerc
		flutter/impeller/tessellator:tessellator_shared
		flutter/build/archives:flutter_patched_sdk
		flutter/sky/packages/sky_engine:sky_engine
	)

	eninja -C out/host_release "${ninja_targets[@]}"
}

src_install() {
	doexe out/host_release/gen_snapshot
	doexe out/host_release/flutter_tester
	doexe out/host_release/impellerc
	dolib.so out/host_release/libflutter_linux_gtk.so
	dolib.so out/host_release/libtessellator.so

	# Install standard flutter-engine directory layout
	insinto "${FLUTTER_ENGINE_ARCH_DIR}"
	doins out/host_release/libflutter_linux_gtk.so
	doins out/host_release/libtessellator.so
	fperms 0755 "${FLUTTER_ENGINE_ARCH_DIR}/libflutter_linux_gtk.so"
	fperms 0755 "${FLUTTER_ENGINE_ARCH_DIR}/libtessellator.so"

	exeinto "${FLUTTER_ENGINE_ARCH_DIR}"
	doexe out/host_release/gen_snapshot
	doexe out/host_release/flutter_tester
	doexe out/host_release/impellerc

	insinto "${FLUTTER_ENGINE_ARCH_DIR}"
	if [[ -f out/host_release/icudtl.dat ]]; then
		doins out/host_release/icudtl.dat
	elif [[ -f flutter/third_party/icu/flutter/icudtl.dat ]]; then
		doins flutter/third_party/icu/flutter/icudtl.dat
	fi

	insinto "/usr/lib/flutter-engine/${PV}/linux-x64/flutter_linux"
	doins out/host_release/flutter_linux/*.h

	insinto /usr/include/flutter-engine/flutter_linux
	doins out/host_release/flutter_linux/*.h

	insinto "/usr/lib/flutter-engine/${PV}/common/flutter_patched_sdk"
	doins out/host_release/flutter_patched_sdk/platform_strong.dill
	doins out/host_release/flutter_patched_sdk/vm_outline_strong.dill

	insinto "/usr/lib/flutter-engine/${PV}/pkg"
	if [[ -d out/host_release/gen/dart-pkg/sky_engine ]]; then
		doins -r out/host_release/gen/dart-pkg/sky_engine
	elif [[ -d flutter/sky/packages/sky_engine ]]; then
		doins -r flutter/sky/packages/sky_engine
	fi
}
