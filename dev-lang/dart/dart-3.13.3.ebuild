# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The Dart SDK, including the VM, dart2js, core libraries, and more"
HOMEPAGE="https://dart.dev/"

DART_GIT="https://dart.googlesource.com"
CHROMIUM_GIT="https://chromium.googlesource.com"
BORINGSSL_GIT="https://boringssl.googlesource.com"
SRC_URI="https://github.com/dart-lang/sdk/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" ${CHROMIUM_GIT}/chromium/llvm-project/cfe/tools/clang-format/+archive/bb994c6f067340c1135eb43eed84f4b33cfa7397.tar.gz -> buildtools-clang_format-script-bb994c6f.tar.gz"
SRC_URI+=" ${DART_GIT}/external/github.com/flutter/devtools/+archive/12d595649f189f1896722623f72599077f476848.tar.gz -> third_party-devtools_src-12d59564.tar.gz"
SRC_URI+=" ${CHROMIUM_GIT}/chromium/src/third_party/markupsafe/+archive/8f45f5cfa0009d2a70589bcda0349b8cb2b72783.tar.gz -> third_party-markupsafe-8f45f5cf.tar.gz"
SRC_URI+=" ${CHROMIUM_GIT}/chromium/src/third_party/zlib/+archive/3008c4b3a06bd65392c31db8846000a21e3d03c5.tar.gz -> third_party-zlib-3008c4b3.tar.gz"
SRC_URI+=" ${CHROMIUM_GIT}/external/github.com/google/cpu_features/+archive/936b9ab5515dead115606559502e3864958f7f6e.tar.gz -> third_party-cpu_features-src-936b9ab5.tar.gz"
SRC_URI+=" ${BORINGSSL_GIT}/boringssl/+archive/2e508c973d634b3aa51b71db5062bc6b096e5031.tar.gz -> third_party-boringssl-src-2e508c97.tar.gz"
SRC_URI+=" ${CHROMIUM_GIT}/external/github.com/WebAssembly/binaryen/+archive/9926156a583cec3d22d521232b31c70fa9a87dc1.tar.gz -> third_party-binaryen-src-9926156a.tar.gz"
SRC_URI+=" ${DART_GIT}/external/github.com/emscripten-core/emsdk/+archive/e41b8c68a248da5f18ebd03bd0420953945d52ff.tar.gz -> third_party-emsdk-e41b8c68.tar.gz"
SRC_URI+=" ${DART_GIT}/external/github.com/flutter/flutter/+archive/ad80825c24d770a19e33f67800fc0338a3b89ec7.tar.gz -> third_party-flutter-ad80825c.tar.gz"
SRC_URI+=" ${CHROMIUM_GIT}/chromium/src/third_party/jinja2/+archive/2222b31554f03e62600cd7e383376a7c187967a1.tar.gz -> third_party-jinja2-2222b315.tar.gz"
SRC_URI+=" ${CHROMIUM_GIT}/chromium/src/third_party/ply/+archive/604b32590ffad5cbb82e4afef1d305512d06ae93.tar.gz -> third_party-ply-604b3259.tar.gz"
SRC_URI+=" ${CHROMIUM_GIT}/chromium/deps/icu/+archive/a86a32e67b8d1384b33f8fa48c83a6079b86f8cd.tar.gz -> third_party-icu-a86a32e6.tar.gz"
SRC_URI+=" ${DART_GIT}/webcore/+archive/bcb10901266c884e7b3740abc597ab95373ab55c.tar.gz -> third_party-WebCore-bcb10901.tar.gz"
SRC_URI+=" ${DART_GIT}/core/+archive/be0b1531c445a185d3e93887b8d0355fc766c314.tar.gz -> third_party-pkg-core-be0b1531.tar.gz"
SRC_URI+=" ${DART_GIT}/dart_style/+archive/39edc2d946a5d7bd1caf6f1695f366b00f7b873c.tar.gz -> third_party-pkg-dart_style-39edc2d9.tar.gz"
SRC_URI+=" ${DART_GIT}/dartdoc/+archive/1d56f263955f329b6701d8f84f069eb0aef353a4.tar.gz -> third_party-pkg-dartdoc-1d56f263.tar.gz"
SRC_URI+=" ${DART_GIT}/ecosystem/+archive/848b3bf3b757d2e9ae4d60030eeed5756c87783f.tar.gz -> third_party-pkg-ecosystem-848b3bf3.tar.gz"
SRC_URI+=" ${DART_GIT}/flute/+archive/b84119fba67016a80c3eb80765762bcc4d0d0b8d.tar.gz -> third_party-flute-b84119fb.tar.gz"
SRC_URI+=" ${DART_GIT}/http/+archive/5d94ef52582867e077bf41c3fa20fb8b1d1d834e.tar.gz -> third_party-pkg-http-5d94ef52.tar.gz"
SRC_URI+=" ${DART_GIT}/i18n/+archive/d0683bdea253d19a4350f5bc2be9017aba61837f.tar.gz -> third_party-pkg-i18n-d0683bde.tar.gz"
SRC_URI+=" ${DART_GIT}/leak_tracker/+archive/f5620600a5ce1c44f65ddaa02001e200b096e14c.tar.gz -> third_party-pkg-leak_tracker-f5620600.tar.gz"
SRC_URI+=" ${DART_GIT}/external/github.com/material-foundation/material-color-utilities/+archive/799b6ba2f3f1c28c67cc7e0b4f18e0c7d7f3c03e.tar.gz -> third_party-pkg-material_color_utilities-799b6ba2.tar.gz"
SRC_URI+=" ${DART_GIT}/native/+archive/d51c53334486af69435b0b45c4bdfe303a830170.tar.gz -> third_party-pkg-native-d51c5333.tar.gz"
SRC_URI+=" ${DART_GIT}/protobuf/+archive/84079e8b8531309e06ba7276b1c28bdca9210ad6.tar.gz -> third_party-pkg-protobuf-84079e8b.tar.gz"
SRC_URI+=" ${DART_GIT}/pub/+archive/ec276d10a7fa0f6c6ec005340fb9ad29f3b012d0.tar.gz -> third_party-pkg-pub-ec276d10.tar.gz"
SRC_URI+=" ${DART_GIT}/shelf/+archive/71248e727317930f244c4b4535e9733bcfc66677.tar.gz -> third_party-pkg-shelf-71248e72.tar.gz"
SRC_URI+=" ${DART_GIT}/sync_http/+archive/6666fff944221891182e1f80bf56569338164d72.tar.gz -> third_party-pkg-sync_http-6666fff9.tar.gz"
SRC_URI+=" ${DART_GIT}/external/github.com/simolus3/tar/+archive/13479f7c2a18f499e840ad470cfcca8c579f6909.tar.gz -> third_party-pkg-tar-13479f7c.tar.gz"
SRC_URI+=" ${DART_GIT}/test/+archive/bd92e633e7f05edc3301865bdc00d1ae181cb1f1.tar.gz -> third_party-pkg-test-bd92e633.tar.gz"
SRC_URI+=" ${DART_GIT}/tools/+archive/7fec8be9af0cd0367d03dbec29b66b3f46565720.tar.gz -> third_party-pkg-tools-7fec8be9.tar.gz"
SRC_URI+=" ${DART_GIT}/external/github.com/google/vector_math.dart/+archive/cf3b5db7340d317dd3489e5a35434b408020a852.tar.gz -> third_party-pkg-vector_math-cf3b5db7.tar.gz"
SRC_URI+=" ${DART_GIT}/external/github.com/google/webdriver.dart/+archive/3a711ebb36871eac997c5d5d2429f7414873dc63.tar.gz -> third_party-pkg-webdriver-3a711ebb.tar.gz"
SRC_URI+=" ${DART_GIT}/external/github.com/google/webkit_inspection_protocol.dart/+archive/762115a971d1968bc940454ad1e88d506d8c5640.tar.gz -> third_party-pkg-webkit_inspection_protocol-762115a9.tar.gz"
SRC_URI+=" ${DART_GIT}/web/+archive/eb8c3fc61a1e35f48f865836c7c7342897d91bcc.tar.gz -> third_party-pkg-web-eb8c3fc6.tar.gz"

PYTHON_COMPAT=( python3_{10..12} )
inherit python-any-r1

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv"

DEPEND="dev-build/gn"
DEPEND+=" dev-build/ninja"
BDEPEND="${DEPEND}"
BDEPEND+=" ${PYTHON_DEPS}"

src_unpack() {
	unpack ${P}.tar.gz
	mv "sdk-${PV}" "${S}" || die
	mkdir -p "${S}/buildtools/clang_format/script" || die
	cd "${S}/buildtools/clang_format/script" || die
	unpack buildtools-clang_format-script-bb994c6f.tar.gz
	mkdir -p "${S}/third_party/devtools_src" || die
	cd "${S}/third_party/devtools_src" || die
	unpack third_party-devtools_src-12d59564.tar.gz
	mkdir -p "${S}/third_party/markupsafe" || die
	cd "${S}/third_party/markupsafe" || die
	unpack third_party-markupsafe-8f45f5cf.tar.gz
	mkdir -p "${S}/third_party/zlib" || die
	cd "${S}/third_party/zlib" || die
	unpack third_party-zlib-3008c4b3.tar.gz
	mkdir -p "${S}/third_party/cpu_features/src" || die
	cd "${S}/third_party/cpu_features/src" || die
	unpack third_party-cpu_features-src-936b9ab5.tar.gz
	mkdir -p "${S}/third_party/boringssl/src" || die
	cd "${S}/third_party/boringssl/src" || die
	unpack third_party-boringssl-src-2e508c97.tar.gz
	mkdir -p "${S}/third_party/binaryen/src" || die
	cd "${S}/third_party/binaryen/src" || die
	unpack third_party-binaryen-src-9926156a.tar.gz
	mkdir -p "${S}/third_party/emsdk" || die
	cd "${S}/third_party/emsdk" || die
	unpack third_party-emsdk-e41b8c68.tar.gz
	mkdir -p "${S}/third_party/flutter" || die
	cd "${S}/third_party/flutter" || die
	unpack third_party-flutter-ad80825c.tar.gz
	mkdir -p "${S}/third_party/jinja2" || die
	cd "${S}/third_party/jinja2" || die
	unpack third_party-jinja2-2222b315.tar.gz
	mkdir -p "${S}/third_party/ply" || die
	cd "${S}/third_party/ply" || die
	unpack third_party-ply-604b3259.tar.gz
	mkdir -p "${S}/third_party/icu" || die
	cd "${S}/third_party/icu" || die
	unpack third_party-icu-a86a32e6.tar.gz
	mkdir -p "${S}/third_party/WebCore" || die
	cd "${S}/third_party/WebCore" || die
	unpack third_party-WebCore-bcb10901.tar.gz
	mkdir -p "${S}/third_party/pkg/core" || die
	cd "${S}/third_party/pkg/core" || die
	unpack third_party-pkg-core-be0b1531.tar.gz
	mkdir -p "${S}/third_party/pkg/dart_style" || die
	cd "${S}/third_party/pkg/dart_style" || die
	unpack third_party-pkg-dart_style-39edc2d9.tar.gz
	mkdir -p "${S}/third_party/pkg/dartdoc" || die
	cd "${S}/third_party/pkg/dartdoc" || die
	unpack third_party-pkg-dartdoc-1d56f263.tar.gz
	mkdir -p "${S}/third_party/pkg/ecosystem" || die
	cd "${S}/third_party/pkg/ecosystem" || die
	unpack third_party-pkg-ecosystem-848b3bf3.tar.gz
	mkdir -p "${S}/third_party/flute" || die
	cd "${S}/third_party/flute" || die
	unpack third_party-flute-b84119fb.tar.gz
	mkdir -p "${S}/third_party/pkg/http" || die
	cd "${S}/third_party/pkg/http" || die
	unpack third_party-pkg-http-5d94ef52.tar.gz
	mkdir -p "${S}/third_party/pkg/i18n" || die
	cd "${S}/third_party/pkg/i18n" || die
	unpack third_party-pkg-i18n-d0683bde.tar.gz
	mkdir -p "${S}/third_party/pkg/leak_tracker" || die
	cd "${S}/third_party/pkg/leak_tracker" || die
	unpack third_party-pkg-leak_tracker-f5620600.tar.gz
	mkdir -p "${S}/third_party/pkg/material_color_utilities" || die
	cd "${S}/third_party/pkg/material_color_utilities" || die
	unpack third_party-pkg-material_color_utilities-799b6ba2.tar.gz
	mkdir -p "${S}/third_party/pkg/native" || die
	cd "${S}/third_party/pkg/native" || die
	unpack third_party-pkg-native-d51c5333.tar.gz
	mkdir -p "${S}/third_party/pkg/protobuf" || die
	cd "${S}/third_party/pkg/protobuf" || die
	unpack third_party-pkg-protobuf-84079e8b.tar.gz
	mkdir -p "${S}/third_party/pkg/pub" || die
	cd "${S}/third_party/pkg/pub" || die
	unpack third_party-pkg-pub-ec276d10.tar.gz
	mkdir -p "${S}/third_party/pkg/shelf" || die
	cd "${S}/third_party/pkg/shelf" || die
	unpack third_party-pkg-shelf-71248e72.tar.gz
	mkdir -p "${S}/third_party/pkg/sync_http" || die
	cd "${S}/third_party/pkg/sync_http" || die
	unpack third_party-pkg-sync_http-6666fff9.tar.gz
	mkdir -p "${S}/third_party/pkg/tar" || die
	cd "${S}/third_party/pkg/tar" || die
	unpack third_party-pkg-tar-13479f7c.tar.gz
	mkdir -p "${S}/third_party/pkg/test" || die
	cd "${S}/third_party/pkg/test" || die
	unpack third_party-pkg-test-bd92e633.tar.gz
	mkdir -p "${S}/third_party/pkg/tools" || die
	cd "${S}/third_party/pkg/tools" || die
	unpack third_party-pkg-tools-7fec8be9.tar.gz
	mkdir -p "${S}/third_party/pkg/vector_math" || die
	cd "${S}/third_party/pkg/vector_math" || die
	unpack third_party-pkg-vector_math-cf3b5db7.tar.gz
	mkdir -p "${S}/third_party/pkg/webdriver" || die
	cd "${S}/third_party/pkg/webdriver" || die
	unpack third_party-pkg-webdriver-3a711ebb.tar.gz
	mkdir -p "${S}/third_party/pkg/webkit_inspection_protocol" || die
	cd "${S}/third_party/pkg/webkit_inspection_protocol" || die
	unpack third_party-pkg-webkit_inspection_protocol-762115a9.tar.gz
	mkdir -p "${S}/third_party/pkg/web" || die
	cd "${S}/third_party/pkg/web" || die
	unpack third_party-pkg-web-eb8c3fc6.tar.gz
}


src_prepare() {
	default
	python_setup
	# Prevent build.py from downloading cipd dependencies
	sed -i -e 's/use_sysroot=True/use_sysroot=False/g' \
		build/config/sysroot.gni || die

	mkdir -p buildtools/ninja || die
	ln -s /usr/bin/gn buildtools/gn || die
	ln -s /usr/bin/ninja buildtools/ninja/ninja || die
}

src_compile() {
	local dart_arch
	case ${ARCH} in
		amd64) dart_arch="X64" ;;
		arm) dart_arch="ARM" ;;
		arm64) dart_arch="ARM64" ;;
		riscv) dart_arch="RISCV64" ;;
	esac
	export DART_USE_SYSROOT="${dart_arch,,}=/"
	./tools/build.py --mode release create_sdk || die
}

src_install() {
	local dart_arch
	case ${ARCH} in
		amd64) dart_arch="X64" ;;
		arm) dart_arch="ARM" ;;
		arm64) dart_arch="ARM64" ;;
		riscv) dart_arch="RISCV64" ;;
	esac
	mkdir -p "${ED}/opt/dart-sdk" || die
	cp -r out/Release${dart_arch}/dart-sdk/* "${ED}/opt/dart-sdk/" || die
	dosym ../dart-sdk/bin/dart /opt/bin/dart
}
