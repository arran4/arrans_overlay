# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The Dart SDK, including the VM, dart2js, core libraries, and more"
HOMEPAGE="https://dart.dev/"

PYTHON_COMPAT=( python3_{10..12} )
inherit python-any-r1

U_AA_0="https://chromium.googlesource.com"
U_AA_1="${U_AA_0}/chromium"
U_AA_2="${U_AA_1}/llvm-project"
U_AA_3="${U_AA_2}/cfe"
U_AA_4="${U_AA_3}/tools"
U_AA_5="${U_AA_4}/clang-format"
U_AA_6="${U_AA_5}/+archive"
U_AA="${U_AA_6}"
U_AB_0="https://dart.googlesource.com"
U_AB_1="${U_AB_0}/external"
U_AB_2="${U_AB_1}/github.com"
U_AB_3="${U_AB_2}/flutter"
U_AB_4="${U_AB_3}/devtools"
U_AB_5="${U_AB_4}/+archive"
U_AB="${U_AB_5}"
U_AC_0="https://chromium.googlesource.com"
U_AC_1="${U_AC_0}/chromium"
U_AC_2="${U_AC_1}/src"
U_AC_3="${U_AC_2}/third_party"
U_AC_4="${U_AC_3}/markupsafe"
U_AC_5="${U_AC_4}/+archive"
U_AC="${U_AC_5}"
U_AD_0="https://chromium.googlesource.com"
U_AD_1="${U_AD_0}/chromium"
U_AD_2="${U_AD_1}/src"
U_AD_3="${U_AD_2}/third_party"
U_AD_4="${U_AD_3}/zlib"
U_AD_5="${U_AD_4}/+archive"
U_AD="${U_AD_5}"
U_AE_0="https://chromium.googlesource.com"
U_AE_1="${U_AE_0}/external"
U_AE_2="${U_AE_1}/github.com"
U_AE_3="${U_AE_2}/google"
U_AE_4="${U_AE_3}/cpu_features"
U_AE_5="${U_AE_4}/+archive"
U_AE="${U_AE_5}"
U_AF_0="https://boringssl.googlesource.com"
U_AF_1="${U_AF_0}/boringssl"
U_AF_2="${U_AF_1}/+archive"
U_AF="${U_AF_2}"
U_AG_0="https://chromium.googlesource.com"
U_AG_1="${U_AG_0}/external"
U_AG_2="${U_AG_1}/github.com"
U_AG_3="${U_AG_2}/WebAssembly"
U_AG_4="${U_AG_3}/binaryen"
U_AG_5="${U_AG_4}/+archive"
U_AG="${U_AG_5}"
U_AH_0="https://dart.googlesource.com"
U_AH_1="${U_AH_0}/external"
U_AH_2="${U_AH_1}/github.com"
U_AH_3="${U_AH_2}/emscripten-core"
U_AH_4="${U_AH_3}/emsdk"
U_AH_5="${U_AH_4}/+archive"
U_AH="${U_AH_5}"
U_AI_0="https://dart.googlesource.com"
U_AI_1="${U_AI_0}/external"
U_AI_2="${U_AI_1}/github.com"
U_AI_3="${U_AI_2}/flutter"
U_AI_4="${U_AI_3}/flutter"
U_AI_5="${U_AI_4}/+archive"
U_AI="${U_AI_5}"
U_AJ_0="https://chromium.googlesource.com"
U_AJ_1="${U_AJ_0}/chromium"
U_AJ_2="${U_AJ_1}/src"
U_AJ_3="${U_AJ_2}/third_party"
U_AJ_4="${U_AJ_3}/jinja2"
U_AJ_5="${U_AJ_4}/+archive"
U_AJ="${U_AJ_5}"
U_AK_0="https://chromium.googlesource.com"
U_AK_1="${U_AK_0}/chromium"
U_AK_2="${U_AK_1}/src"
U_AK_3="${U_AK_2}/third_party"
U_AK_4="${U_AK_3}/ply"
U_AK_5="${U_AK_4}/+archive"
U_AK="${U_AK_5}"
U_AL_0="https://chromium.googlesource.com"
U_AL_1="${U_AL_0}/chromium"
U_AL_2="${U_AL_1}/deps"
U_AL_3="${U_AL_2}/icu"
U_AL_4="${U_AL_3}/+archive"
U_AL="${U_AL_4}"
U_AM_0="https://dart.googlesource.com"
U_AM_1="${U_AM_0}/webcore"
U_AM_2="${U_AM_1}/+archive"
U_AM="${U_AM_2}"
U_AN_0="https://dart.googlesource.com"
U_AN_1="${U_AN_0}/core"
U_AN_2="${U_AN_1}/+archive"
U_AN="${U_AN_2}"
U_AO_0="https://dart.googlesource.com"
U_AO_1="${U_AO_0}/dart_style"
U_AO_2="${U_AO_1}/+archive"
U_AO="${U_AO_2}"
U_AP_0="https://dart.googlesource.com"
U_AP_1="${U_AP_0}/dartdoc"
U_AP_2="${U_AP_1}/+archive"
U_AP="${U_AP_2}"
U_AQ_0="https://dart.googlesource.com"
U_AQ_1="${U_AQ_0}/ecosystem"
U_AQ_2="${U_AQ_1}/+archive"
U_AQ="${U_AQ_2}"
U_AR_0="https://dart.googlesource.com"
U_AR_1="${U_AR_0}/flute"
U_AR_2="${U_AR_1}/+archive"
U_AR="${U_AR_2}"
U_AS_0="https://dart.googlesource.com"
U_AS_1="${U_AS_0}/http"
U_AS_2="${U_AS_1}/+archive"
U_AS="${U_AS_2}"
U_AT_0="https://dart.googlesource.com"
U_AT_1="${U_AT_0}/i18n"
U_AT_2="${U_AT_1}/+archive"
U_AT="${U_AT_2}"
U_AU_0="https://dart.googlesource.com"
U_AU_1="${U_AU_0}/leak_tracker"
U_AU_2="${U_AU_1}/+archive"
U_AU="${U_AU_2}"
U_AV_0="https://dart.googlesource.com"
U_AV_1="${U_AV_0}/external"
U_AV_2="${U_AV_1}/github.com"
U_AV_3="${U_AV_2}/material-foundation"
U_AV_4="${U_AV_3}/material-color-utilities"
U_AV_5="${U_AV_4}/+archive"
U_AV="${U_AV_5}"
U_AW_0="https://dart.googlesource.com"
U_AW_1="${U_AW_0}/native"
U_AW_2="${U_AW_1}/+archive"
U_AW="${U_AW_2}"
U_AX_0="https://dart.googlesource.com"
U_AX_1="${U_AX_0}/protobuf"
U_AX_2="${U_AX_1}/+archive"
U_AX="${U_AX_2}"
U_AY_0="https://dart.googlesource.com"
U_AY_1="${U_AY_0}/pub"
U_AY_2="${U_AY_1}/+archive"
U_AY="${U_AY_2}"
U_AZ_0="https://dart.googlesource.com"
U_AZ_1="${U_AZ_0}/shelf"
U_AZ_2="${U_AZ_1}/+archive"
U_AZ="${U_AZ_2}"
U_BA_0="https://dart.googlesource.com"
U_BA_1="${U_BA_0}/sync_http"
U_BA_2="${U_BA_1}/+archive"
U_BA="${U_BA_2}"
U_BB_0="https://dart.googlesource.com"
U_BB_1="${U_BB_0}/external"
U_BB_2="${U_BB_1}/github.com"
U_BB_3="${U_BB_2}/simolus3"
U_BB_4="${U_BB_3}/tar"
U_BB_5="${U_BB_4}/+archive"
U_BB="${U_BB_5}"
U_BC_0="https://dart.googlesource.com"
U_BC_1="${U_BC_0}/test"
U_BC_2="${U_BC_1}/+archive"
U_BC="${U_BC_2}"
U_BD_0="https://dart.googlesource.com"
U_BD_1="${U_BD_0}/tools"
U_BD_2="${U_BD_1}/+archive"
U_BD="${U_BD_2}"
U_BE_0="https://dart.googlesource.com"
U_BE_1="${U_BE_0}/external"
U_BE_2="${U_BE_1}/github.com"
U_BE_3="${U_BE_2}/google"
U_BE_4="${U_BE_3}/vector_math.dart"
U_BE_5="${U_BE_4}/+archive"
U_BE="${U_BE_5}"
U_BF_0="https://dart.googlesource.com"
U_BF_1="${U_BF_0}/external"
U_BF_2="${U_BF_1}/github.com"
U_BF_3="${U_BF_2}/google"
U_BF_4="${U_BF_3}/webdriver.dart"
U_BF_5="${U_BF_4}/+archive"
U_BF="${U_BF_5}"
U_BG_0="https://dart.googlesource.com"
U_BG_1="${U_BG_0}/external"
U_BG_2="${U_BG_1}/github.com"
U_BG_3="${U_BG_2}/google"
U_BG_4="${U_BG_3}/webkit_inspection_protocol.dart"
U_BG_5="${U_BG_4}/+archive"
U_BG="${U_BG_5}"
U_BH_0="https://dart.googlesource.com"
U_BH_1="${U_BH_0}/web"
U_BH_2="${U_BH_1}/+archive"
U_BH="${U_BH_2}"
SRC_URI="
	https://github.com/dart-lang/sdk/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
	${U_AA}/bb994c6f067340c1135eb43eed84f4b33cfa7397.tar.gz
		-> buildtools-clang_format-script-bb994c6f.tar.gz
	${U_AB}/12d595649f189f1896722623f72599077f476848.tar.gz
		-> third_party-devtools_src-12d59564.tar.gz
	${U_AC}/8f45f5cfa0009d2a70589bcda0349b8cb2b72783.tar.gz
		-> third_party-markupsafe-8f45f5cf.tar.gz
	${U_AD}/3008c4b3a06bd65392c31db8846000a21e3d03c5.tar.gz
		-> third_party-zlib-3008c4b3.tar.gz
	${U_AE}/936b9ab5515dead115606559502e3864958f7f6e.tar.gz
		-> third_party-cpu_features-src-936b9ab5.tar.gz
	${U_AF}/2e508c973d634b3aa51b71db5062bc6b096e5031.tar.gz
		-> third_party-boringssl-src-2e508c97.tar.gz
	${U_AG}/9926156a583cec3d22d521232b31c70fa9a87dc1.tar.gz
		-> third_party-binaryen-src-9926156a.tar.gz
	${U_AH}/e41b8c68a248da5f18ebd03bd0420953945d52ff.tar.gz
		-> third_party-emsdk-e41b8c68.tar.gz
	${U_AI}/ad80825c24d770a19e33f67800fc0338a3b89ec7.tar.gz
		-> third_party-flutter-ad80825c.tar.gz
	${U_AJ}/2222b31554f03e62600cd7e383376a7c187967a1.tar.gz
		-> third_party-jinja2-2222b315.tar.gz
	${U_AK}/604b32590ffad5cbb82e4afef1d305512d06ae93.tar.gz
		-> third_party-ply-604b3259.tar.gz
	${U_AL}/a86a32e67b8d1384b33f8fa48c83a6079b86f8cd.tar.gz
		-> third_party-icu-a86a32e6.tar.gz
	${U_AM}/bcb10901266c884e7b3740abc597ab95373ab55c.tar.gz
		-> third_party-WebCore-bcb10901.tar.gz
	${U_AN}/be0b1531c445a185d3e93887b8d0355fc766c314.tar.gz
		-> third_party-pkg-core-be0b1531.tar.gz
	${U_AO}/39edc2d946a5d7bd1caf6f1695f366b00f7b873c.tar.gz
		-> third_party-pkg-dart_style-39edc2d9.tar.gz
	${U_AP}/1d56f263955f329b6701d8f84f069eb0aef353a4.tar.gz
		-> third_party-pkg-dartdoc-1d56f263.tar.gz
	${U_AQ}/848b3bf3b757d2e9ae4d60030eeed5756c87783f.tar.gz
		-> third_party-pkg-ecosystem-848b3bf3.tar.gz
	${U_AR}/b84119fba67016a80c3eb80765762bcc4d0d0b8d.tar.gz
		-> third_party-flute-b84119fb.tar.gz
	${U_AS}/5d94ef52582867e077bf41c3fa20fb8b1d1d834e.tar.gz
		-> third_party-pkg-http-5d94ef52.tar.gz
	${U_AT}/d0683bdea253d19a4350f5bc2be9017aba61837f.tar.gz
		-> third_party-pkg-i18n-d0683bde.tar.gz
	${U_AU}/f5620600a5ce1c44f65ddaa02001e200b096e14c.tar.gz
		-> third_party-pkg-leak_tracker-f5620600.tar.gz
	${U_AV}/799b6ba2f3f1c28c67cc7e0b4f18e0c7d7f3c03e.tar.gz
		-> third_party-pkg-material_color_utilities-799b6ba2.tar.gz
	${U_AW}/d51c53334486af69435b0b45c4bdfe303a830170.tar.gz
		-> third_party-pkg-native-d51c5333.tar.gz
	${U_AX}/84079e8b8531309e06ba7276b1c28bdca9210ad6.tar.gz
		-> third_party-pkg-protobuf-84079e8b.tar.gz
	${U_AY}/ec276d10a7fa0f6c6ec005340fb9ad29f3b012d0.tar.gz
		-> third_party-pkg-pub-ec276d10.tar.gz
	${U_AZ}/71248e727317930f244c4b4535e9733bcfc66677.tar.gz
		-> third_party-pkg-shelf-71248e72.tar.gz
	${U_BA}/6666fff944221891182e1f80bf56569338164d72.tar.gz
		-> third_party-pkg-sync_http-6666fff9.tar.gz
	${U_BB}/13479f7c2a18f499e840ad470cfcca8c579f6909.tar.gz
		-> third_party-pkg-tar-13479f7c.tar.gz
	${U_BC}/bd92e633e7f05edc3301865bdc00d1ae181cb1f1.tar.gz
		-> third_party-pkg-test-bd92e633.tar.gz
	${U_BD}/7fec8be9af0cd0367d03dbec29b66b3f46565720.tar.gz
		-> third_party-pkg-tools-7fec8be9.tar.gz
	${U_BE}/cf3b5db7340d317dd3489e5a35434b408020a852.tar.gz
		-> third_party-pkg-vector_math-cf3b5db7.tar.gz
	${U_BF}/3a711ebb36871eac997c5d5d2429f7414873dc63.tar.gz
		-> third_party-pkg-webdriver-3a711ebb.tar.gz
	${U_BG}/762115a971d1968bc940454ad1e88d506d8c5640.tar.gz
		-> third_party-pkg-webkit_inspection_protocol-762115a9.tar.gz
	${U_BH}/eb8c3fc61a1e35f48f865836c7c7342897d91bcc.tar.gz
		-> third_party-pkg-web-eb8c3fc6.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv"

DEPEND="dev-build/gn dev-build/ninja"
BDEPEND="${DEPEND} ${PYTHON_DEPS}"

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
