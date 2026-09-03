# Copyright 2024 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Cross-platform Flutter app for GGUF / llama.cpp models locally"
LICENSE="MIT"
HOMEPAGE="https://github.com/Mobile-Artificial-Intelligence/maid"
PUB="pub.dev/api/archives"
MAID_SRC="github.com/Mobile-Artificial-Intelligence/maid/archive/refs/tags"
MAID_LLM_COMMIT="c73dd4b70c9e0463f88222b5fd2d8a60f80af16d"
BABYLON_TTS_COMMIT="94b9ba2228a822be661bc479fe3a323a21023840"
LLAMA_CPP_COMMIT="7237e1ffe2803f8fe6facf8990610c4f17254793"
FLUTTER_PV="3.47.2"
FLUTTER_ENGINE_COMMIT="a804b261645ef8c13eb3d5c44a5c2fb0340c5539"
SRC_URI="https://${MAID_SRC}/${PV}.tar.gz -> maid-${PV}.tar.gz \
	https://github.com/Mobile-Artificial-Intelligence/maid_llm/archive/${MAID_LLM_COMMIT}.tar.gz -> maid_llm-${MAID_LLM_COMMIT}.tar.gz \
	https://github.com/KevinSerres/babylon_tts/archive/${BABYLON_TTS_COMMIT}.tar.gz -> babylon_tts-${BABYLON_TTS_COMMIT}.tar.gz \
	https://github.com/ggml-org/llama.cpp/archive/${LLAMA_CPP_COMMIT}.tar.gz -> llama.cpp-${LLAMA_CPP_COMMIT}.tar.gz \
	https://storage.googleapis.com/flutter_infra_release/flutter/${FLUTTER_ENGINE_COMMIT}/linux-x64-debug/linux-x64-flutter-gtk.zip -> flutter-linux-x64-debug-${FLUTTER_ENGINE_COMMIT}.zip \
	https://storage.googleapis.com/flutter_infra_release/flutter/${FLUTTER_ENGINE_COMMIT}/linux-x64-profile/linux-x64-flutter-gtk.zip -> flutter-linux-x64-profile-${FLUTTER_ENGINE_COMMIT}.zip \
	https://storage.googleapis.com/flutter_infra_release/flutter/${FLUTTER_ENGINE_COMMIT}/linux-x64-release/linux-x64-flutter-gtk.zip -> flutter-linux-x64-release-${FLUTTER_ENGINE_COMMIT}.zip \
	https://${PUB}/_fe_analyzer_shared-67.0.0.tar.gz \
	https://${PUB}/analyzer-6.4.1.tar.gz \
	https://${PUB}/archive-3.6.1.tar.gz \
	https://${PUB}/args-2.5.0.tar.gz \
	https://${PUB}/async-2.11.0.tar.gz \
	https://${PUB}/audioplayers-6.0.0.tar.gz \
	https://${PUB}/audioplayers_android-5.0.0.tar.gz \
	https://${PUB}/audioplayers_darwin-6.0.0.tar.gz \
	https://${PUB}/audioplayers_linux-4.0.0.tar.gz \
	https://${PUB}/audioplayers_platform_interface-7.0.0.tar.gz \
	https://${PUB}/audioplayers_web-5.0.0.tar.gz \
	https://${PUB}/audioplayers_windows-4.0.0.tar.gz \
	https://${PUB}/boolean_selector-2.1.1.tar.gz \
	https://${PUB}/build-2.4.1.tar.gz \
	https://${PUB}/built_collection-5.1.1.tar.gz \
	https://${PUB}/built_value-8.9.2.tar.gz \
	https://${PUB}/characters-1.4.1.tar.gz \
	https://${PUB}/checked_yaml-2.0.3.tar.gz \
	https://${PUB}/cli_util-0.4.1.tar.gz \
	https://${PUB}/clock-1.1.3.tar.gz \
	https://${PUB}/code_builder-4.10.0.tar.gz \
	https://${PUB}/collection-1.19.1.tar.gz \
	https://${PUB}/convert-3.1.1.tar.gz \
	https://${PUB}/cross_file-0.3.4+1.tar.gz \
	https://${PUB}/crypto-3.0.3.tar.gz \
	https://${PUB}/cupertino_icons-1.0.8.tar.gz \
	https://${PUB}/dart_ping-9.0.1.tar.gz \
	https://${PUB}/dart_style-2.3.6.tar.gz \
	https://${PUB}/dbus-0.7.10.tar.gz \
	https://${PUB}/device_info_plus-9.1.2.tar.gz \
	https://${PUB}/device_info_plus_platform_interface-7.0.0.tar.gz \
	https://${PUB}/dio-5.4.3+1.tar.gz \
	https://${PUB}/fake_async-1.3.3.tar.gz \
	https://${PUB}/fetch_api-2.2.0.tar.gz \
	https://${PUB}/fetch_client-1.1.2.tar.gz \
	https://${PUB}/ffi-2.1.2.tar.gz \
	https://${PUB}/file-7.0.0.tar.gz \
	https://${PUB}/file_picker-8.0.4.tar.gz \
	https://${PUB}/fixnum-1.1.0.tar.gz \
	https://${PUB}/flutter_launcher_icons-0.13.1.tar.gz \
	https://${PUB}/flutter_lints-3.0.2.tar.gz \
	https://${PUB}/flutter_plugin_android_lifecycle-2.0.20.tar.gz \
	https://${PUB}/flutter_resizable_container-2.0.0.tar.gz \
	https://${PUB}/flutter_svg-2.0.10+1.tar.gz \
	https://${PUB}/freezed_annotation-2.4.1.tar.gz \
	https://${PUB}/glob-2.1.2.tar.gz \
	https://${PUB}/globbing-1.0.0.tar.gz \
	https://${PUB}/google_generative_ai-0.2.3.tar.gz \
	https://${PUB}/http-1.2.1.tar.gz \
	https://${PUB}/http_parser-4.0.2.tar.gz \
	https://${PUB}/image-4.2.0.tar.gz \
	https://${PUB}/json_annotation-4.9.0.tar.gz \
	https://${PUB}/lan_scanner-4.0.0+1.tar.gz \
	https://${PUB}/langchain-0.5.0+1.tar.gz \
	https://${PUB}/langchain_core-0.1.0.tar.gz \
	https://${PUB}/langchain_mistralai-0.1.0.tar.gz \
	https://${PUB}/langchain_ollama-0.1.0.tar.gz \
	https://${PUB}/langchain_openai-0.5.0+1.tar.gz \
	https://${PUB}/langchain_tiktoken-1.0.1.tar.gz \
	https://${PUB}/leak_tracker-11.0.2.tar.gz \
	https://${PUB}/leak_tracker_flutter_testing-3.0.10.tar.gz \
	https://${PUB}/leak_tracker_testing-3.0.2.tar.gz \
	https://${PUB}/lints-3.0.0.tar.gz \
	https://${PUB}/logging-1.2.0.tar.gz \
	https://${PUB}/matcher-0.12.20.tar.gz \
	https://${PUB}/material_color_utilities-0.13.0.tar.gz \
	https://${PUB}/meta-1.19.0.tar.gz \
	https://${PUB}/mistralai_dart-0.0.3+2.tar.gz \
	https://${PUB}/mockito-5.4.4.tar.gz \
	https://${PUB}/nested-1.0.0.tar.gz \
	https://${PUB}/network_info_plus-4.1.0+1.tar.gz \
	https://${PUB}/network_info_plus_platform_interface-1.1.3.tar.gz \
	https://${PUB}/nm-0.5.0.tar.gz \
	https://${PUB}/ollama_dart-0.0.3+1.tar.gz \
	https://${PUB}/openai_dart-0.2.2.tar.gz \
	https://${PUB}/package_config-2.1.0.tar.gz \
	https://${PUB}/path-1.9.1.tar.gz \
	https://${PUB}/path_parsing-1.0.1.tar.gz \
	https://${PUB}/path_provider-2.1.3.tar.gz \
	https://${PUB}/path_provider_android-2.2.5.tar.gz \
	https://${PUB}/path_provider_foundation-2.4.0.tar.gz \
	https://${PUB}/path_provider_linux-2.2.1.tar.gz \
	https://${PUB}/path_provider_platform_interface-2.1.2.tar.gz \
	https://${PUB}/path_provider_windows-2.2.1.tar.gz \
	https://${PUB}/permission_handler-11.3.1.tar.gz \
	https://${PUB}/permission_handler_android-12.0.6.tar.gz \
	https://${PUB}/permission_handler_apple-9.4.5.tar.gz \
	https://${PUB}/permission_handler_html-0.1.1.tar.gz \
	https://${PUB}/permission_handler_platform_interface-4.2.1.tar.gz \
	https://${PUB}/permission_handler_windows-0.2.1.tar.gz \
	https://${PUB}/petitparser-6.0.2.tar.gz \
	https://${PUB}/platform-3.1.4.tar.gz \
	https://${PUB}/plugin_platform_interface-2.1.8.tar.gz \
	https://${PUB}/process-5.0.2.tar.gz \
	https://${PUB}/provider-6.1.2.tar.gz \
	https://${PUB}/pub_semver-2.1.4.tar.gz \
	https://${PUB}/receive_sharing_intent-1.8.0.tar.gz \
	https://${PUB}/shared_preferences-2.2.3.tar.gz \
	https://${PUB}/shared_preferences_android-2.2.3.tar.gz \
	https://${PUB}/shared_preferences_foundation-2.4.0.tar.gz \
	https://${PUB}/shared_preferences_linux-2.3.2.tar.gz \
	https://${PUB}/shared_preferences_platform_interface-2.3.2.tar.gz \
	https://${PUB}/shared_preferences_web-2.3.0.tar.gz \
	https://${PUB}/shared_preferences_windows-2.3.2.tar.gz \
	https://${PUB}/source_gen-1.5.0.tar.gz \
	https://${PUB}/source_span-1.10.0.tar.gz \
	https://${PUB}/sprintf-7.0.0.tar.gz \
	https://${PUB}/stack_trace-1.12.2.tar.gz \
	https://${PUB}/stream_channel-2.1.4.tar.gz \
	https://${PUB}/string_scanner-1.2.0.tar.gz \
	https://${PUB}/sync_http-0.3.1.tar.gz \
	https://${PUB}/synchronized-3.1.0+1.tar.gz \
	https://${PUB}/system_info2-4.0.0.tar.gz \
	https://${PUB}/term_glyph-1.2.1.tar.gz \
	https://${PUB}/test_api-0.7.12.tar.gz \
	https://${PUB}/typed_data-1.3.2.tar.gz \
	https://${PUB}/uuid-4.4.0.tar.gz \
	https://${PUB}/vector_graphics-1.1.11+1.tar.gz \
	https://${PUB}/vector_graphics_codec-1.1.11+1.tar.gz \
	https://${PUB}/vector_graphics_compiler-1.1.11+1.tar.gz \
	https://${PUB}/vector_math-2.4.2.tar.gz \
	https://${PUB}/vm_service-14.2.1.tar.gz \
	https://${PUB}/watcher-1.1.0.tar.gz \
	https://${PUB}/web-0.5.1.tar.gz \
	https://${PUB}/webdriver-3.0.3.tar.gz \
	https://${PUB}/win32-5.5.1.tar.gz \
	https://${PUB}/win32_registry-1.1.3.tar.gz \
	https://${PUB}/xdg_directories-1.0.4.tar.gz \
	https://${PUB}/xml-6.5.0.tar.gz \
	https://${PUB}/yaml-3.1.2.tar.gz"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="!app-misc/maid-appimage media-libs/gstreamer:1.0 media-libs/gst-plugins-base:1.0 media-libs/vulkan-loader x11-libs/gtk+:3 x11-libs/pango"
DEPEND="${RDEPEND} dev-util/vulkan-headers"
BDEPEND="=dev-lang/flutter-bin-${FLUTTER_PV}* app-arch/unzip dev-build/ninja dev-build/cmake"
BDEPEND+=" virtual/pkgconfig"

src_unpack() {
	local file pkg_ver
	local pub_cache="${WORKDIR}/pub-cache"

	unpack "${P}.tar.gz"
	mkdir -p \
		"${S}/packages/maid_llm" \
		"${S}/packages/maid_llm/src/llama_cpp" \
		"${S}/packages/babylon_tts" \
		"${pub_cache}/hosted/pub.dev" || die
	tar -xzf "${DISTDIR}/maid_llm-${MAID_LLM_COMMIT}.tar.gz" \
		-C "${S}/packages/maid_llm" --strip-components=1 || die
	tar -xzf "${DISTDIR}/babylon_tts-${BABYLON_TTS_COMMIT}.tar.gz" \
		-C "${S}/packages/babylon_tts" --strip-components=1 || die
	tar -xzf "${DISTDIR}/llama.cpp-${LLAMA_CPP_COMMIT}.tar.gz" \
		-C "${S}/packages/maid_llm/src/llama_cpp" --strip-components=1 || die

	for file in ${A}; do
		case ${file} in
			"${P}.tar.gz"|"maid_llm-${MAID_LLM_COMMIT}.tar.gz"|"babylon_tts-${BABYLON_TTS_COMMIT}.tar.gz"|"llama.cpp-${LLAMA_CPP_COMMIT}.tar.gz")
				continue
				;;
		esac
		[[ ${file} == *.tar.gz ]] || continue

		pkg_ver=${file%.tar.gz}
		mkdir -p "${pub_cache}/hosted/pub.dev/${pkg_ver}" || die
		tar -xzf "${DISTDIR}/${file}" \
			-C "${pub_cache}/hosted/pub.dev/${pkg_ver}" || die
	done
}

src_prepare() {
	default

	# These old LangChain releases work with collection-1.19, but their
	# published upper bounds predate the version required by Flutter 3.47.
	sed -i '/^dev_dependencies:/i dependency_overrides:\n  collection: 1.19.1\n' \
		pubspec.yaml || die
}

src_compile() {
	local mode

	export FLUTTER_CACHE_DIR="${WORKDIR}/flutter-cache"
	export PUB_CACHE="${WORKDIR}/pub-cache"
	mkdir -p "${FLUTTER_CACHE_DIR}" || die
	cp -a --reflink=auto /opt/flutter/bin/cache/. "${FLUTTER_CACHE_DIR}/" || die
	chmod -R u+rwX "${FLUTTER_CACHE_DIR}" || die
	for mode in debug profile release; do
		mkdir -p "${FLUTTER_CACHE_DIR}/artifacts/engine/linux-x64-${mode}" || die
		unzip -q \
			"${DISTDIR}/flutter-linux-x64-${mode}-${FLUTTER_ENGINE_COMMIT}.zip" \
			-d "${FLUTTER_CACHE_DIR}/artifacts/engine/linux-x64-${mode}" || die
	done
	printf '%s\n' "${FLUTTER_ENGINE_COMMIT}" \
		> "${FLUTTER_CACHE_DIR}/linux-sdk.stamp" || die

	flutter config --no-analytics || die
	flutter pub get --offline || die
	flutter build linux --release --no-pub || die
}

src_install() {
	insinto /opt/maid
	doins -r build/linux/x64/release/bundle/*
	fperms +x /opt/maid/maid
	dosym ../../opt/maid/maid /usr/bin/maid

	# Install desktop file and icon
	doicon -s 256 assets/maid.png
	make_desktop_entry maid Maid maid Utility
}
