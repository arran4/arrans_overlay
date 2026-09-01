# Copyright 2024 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Cross-platform Flutter app for GGUF / llama.cpp models locally"
HOMEPAGE="https://github.com/Mobile-Artificial-Intelligence/maid"
PUB_API="https://pub.dev/api/archives"
PERM_PI="permission_handler_platform_interface"
PREFS_PI="shared_preferences_platform_interface"
LTRACKER_F="leak_tracker_flutter_testing"
LTRACKER_T="leak_tracker_testing"
LTRACKER="leak_tracker"
NET_INFO="network_info_plus_platform_interface"
DEV_INFO="device_info_plus_platform_interface"
FL_PLUGIN="flutter_plugin_android_lifecycle"
PATH_PROV="path_provider_platform_interface"
AUDIO_PI="audioplayers_platform_interface"
MAID_GH="Mobile-Artificial-Intelligence"
SRC_URI="https://github.com/Mobile-Artificial-Intelligence/maid/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz \
	${PUB_API}/_fe_analyzer_shared-67.0.0.tar.gz \
	${PUB_API}/analyzer-6.4.1.tar.gz \
	${PUB_API}/archive-3.6.1.tar.gz \
	${PUB_API}/args-2.5.0.tar.gz \
	${PUB_API}/async-2.11.0.tar.gz \
	${PUB_API}/audioplayers-6.0.0.tar.gz \
	${PUB_API}/audioplayers_android-5.0.0.tar.gz \
	${PUB_API}/audioplayers_darwin-6.0.0.tar.gz \
	${PUB_API}/audioplayers_linux-4.0.0.tar.gz \
	${PUB_API}/${AUDIO_PI}-7.0.0.tar.gz \
	${PUB_API}/audioplayers_web-5.0.0.tar.gz \
	${PUB_API}/audioplayers_windows-4.0.0.tar.gz \
	${PUB_API}/boolean_selector-2.1.1.tar.gz \
	${PUB_API}/build-2.4.1.tar.gz \
	${PUB_API}/built_collection-5.1.1.tar.gz \
	${PUB_API}/built_value-8.9.2.tar.gz \
	${PUB_API}/characters-1.3.0.tar.gz \
	${PUB_API}/checked_yaml-2.0.3.tar.gz \
	${PUB_API}/cli_util-0.4.1.tar.gz \
	${PUB_API}/clock-1.1.1.tar.gz \
	${PUB_API}/code_builder-4.10.0.tar.gz \
	${PUB_API}/collection-1.18.0.tar.gz \
	${PUB_API}/convert-3.1.1.tar.gz \
	${PUB_API}/cross_file-0.3.4+1.tar.gz \
	${PUB_API}/crypto-3.0.3.tar.gz \
	${PUB_API}/cupertino_icons-1.0.8.tar.gz \
	${PUB_API}/dart_ping-9.0.1.tar.gz \
	${PUB_API}/dart_style-2.3.6.tar.gz \
	${PUB_API}/dbus-0.7.10.tar.gz \
	${PUB_API}/device_info_plus-9.1.2.tar.gz \
	${PUB_API}/${DEV_INFO}-7.0.0.tar.gz \
	${PUB_API}/dio-5.4.3+1.tar.gz \
	${PUB_API}/fake_async-1.3.1.tar.gz \
	${PUB_API}/fetch_api-2.2.0.tar.gz \
	${PUB_API}/fetch_client-1.1.2.tar.gz \
	${PUB_API}/ffi-2.1.2.tar.gz \
	${PUB_API}/file-7.0.0.tar.gz \
	${PUB_API}/file_picker-8.0.4.tar.gz \
	${PUB_API}/fixnum-1.1.0.tar.gz \
	${PUB_API}/flutter_launcher_icons-0.13.1.tar.gz \
	${PUB_API}/flutter_lints-3.0.2.tar.gz \
	${PUB_API}/${FL_PLUGIN}-2.0.20.tar.gz \
	${PUB_API}/flutter_resizable_container-2.0.0.tar.gz \
	${PUB_API}/flutter_svg-2.0.10+1.tar.gz \
	${PUB_API}/freezed_annotation-2.4.1.tar.gz \
	${PUB_API}/glob-2.1.2.tar.gz \
	${PUB_API}/globbing-1.0.0.tar.gz \
	${PUB_API}/google_generative_ai-0.2.3.tar.gz \
	${PUB_API}/http-1.2.1.tar.gz \
	-> http-1.2.1.tar.gz \
	${PUB_API}/http_parser-4.0.2.tar.gz \
	-> http_parser-4.0.2.tar.gz \
	${PUB_API}/image-4.2.0.tar.gz \
	${PUB_API}/json_annotation-4.9.0.tar.gz \
	${PUB_API}/lan_scanner-4.0.0+1.tar.gz \
	${PUB_API}/langchain-0.5.0+1.tar.gz \
	${PUB_API}/langchain_core-0.1.0.tar.gz \
	${PUB_API}/langchain_mistralai-0.1.0.tar.gz \
	${PUB_API}/langchain_ollama-0.1.0.tar.gz \
	${PUB_API}/langchain_openai-0.5.0+1.tar.gz \
	${PUB_API}/langchain_tiktoken-1.0.1.tar.gz \
	${PUB_API}/${LTRACKER}-10.0.4.tar.gz \
	${PUB_API}/${LTRACKER_F}-3.0.3.tar.gz \
	${PUB_API}/${LTRACKER_T}-3.0.1.tar.gz \
	${PUB_API}/lints-3.0.0.tar.gz \
	${PUB_API}/logging-1.2.0.tar.gz \
	${PUB_API}/matcher-0.12.16+1.tar.gz \
	${PUB_API}/material_color_utilities-0.8.0.tar.gz \
	${PUB_API}/meta-1.12.0.tar.gz \
	${PUB_API}/mistralai_dart-0.0.3+2.tar.gz \
	${PUB_API}/mockito-5.4.4.tar.gz \
	${PUB_API}/nested-1.0.0.tar.gz \
	${PUB_API}/network_info_plus-4.1.0+1.tar.gz \
	${PUB_API}/${NET_INFO}-1.1.3.tar.gz \
	${PUB_API}/nm-0.5.0.tar.gz \
	${PUB_API}/ollama_dart-0.0.3+1.tar.gz \
	${PUB_API}/openai_dart-0.2.2.tar.gz \
	${PUB_API}/package_config-2.1.0.tar.gz \
	${PUB_API}/path-1.9.0.tar.gz \
	${PUB_API}/path_parsing-1.0.1.tar.gz \
	${PUB_API}/path_provider-2.1.3.tar.gz \
	${PUB_API}/path_provider_android-2.2.5.tar.gz \
	${PUB_API}/path_provider_foundation-2.4.0.tar.gz \
	${PUB_API}/path_provider_linux-2.2.1.tar.gz \
	${PUB_API}/${PATH_PROV}-2.1.2.tar.gz \
	${PUB_API}/path_provider_windows-2.2.1.tar.gz \
	${PUB_API}/permission_handler-11.3.1.tar.gz \
	${PUB_API}/permission_handler_android-12.0.6.tar.gz \
	${PUB_API}/permission_handler_apple-9.4.5.tar.gz \
	${PUB_API}/permission_handler_html-0.1.1.tar.gz \
	${PUB_API}/${PERM_PI}-4.2.1.tar.gz \
	${PUB_API}/permission_handler_windows-0.2.1.tar.gz \
	${PUB_API}/petitparser-6.0.2.tar.gz \
	${PUB_API}/platform-3.1.4.tar.gz \
	${PUB_API}/plugin_platform_interface-2.1.8.tar.gz \
	${PUB_API}/process-5.0.2.tar.gz \
	${PUB_API}/provider-6.1.2.tar.gz \
	${PUB_API}/pub_semver-2.1.4.tar.gz \
	${PUB_API}/receive_sharing_intent-1.8.0.tar.gz \
	${PUB_API}/shared_preferences-2.2.3.tar.gz \
	${PUB_API}/shared_preferences_android-2.2.3.tar.gz \
	${PUB_API}/shared_preferences_foundation-2.4.0.tar.gz \
	${PUB_API}/shared_preferences_linux-2.3.2.tar.gz \
	${PUB_API}/${PREFS_PI}-2.3.2.tar.gz \
	${PUB_API}/shared_preferences_web-2.3.0.tar.gz \
	${PUB_API}/shared_preferences_windows-2.3.2.tar.gz \
	${PUB_API}/source_gen-1.5.0.tar.gz \
	${PUB_API}/source_span-1.10.0.tar.gz \
	${PUB_API}/sprintf-7.0.0.tar.gz \
	${PUB_API}/stack_trace-1.11.1.tar.gz \
	${PUB_API}/stream_channel-2.1.2.tar.gz \
	${PUB_API}/string_scanner-1.2.0.tar.gz \
	${PUB_API}/sync_http-0.3.1.tar.gz \
	-> sync_http-0.3.1.tar.gz \
	${PUB_API}/synchronized-3.1.0+1.tar.gz \
	${PUB_API}/system_info2-4.0.0.tar.gz \
	${PUB_API}/term_glyph-1.2.1.tar.gz \
	${PUB_API}/test_api-0.7.0.tar.gz \
	${PUB_API}/typed_data-1.3.2.tar.gz \
	${PUB_API}/uuid-4.4.0.tar.gz \
	${PUB_API}/vector_graphics-1.1.11+1.tar.gz \
	${PUB_API}/vector_graphics_codec-1.1.11+1.tar.gz \
	${PUB_API}/vector_graphics_compiler-1.1.11+1.tar.gz \
	${PUB_API}/vector_math-2.1.4.tar.gz \
	${PUB_API}/vm_service-14.2.1.tar.gz \
	${PUB_API}/watcher-1.1.0.tar.gz \
	${PUB_API}/web-0.5.1.tar.gz \
	${PUB_API}/webdriver-3.0.3.tar.gz \
	${PUB_API}/win32-5.5.1.tar.gz \
	${PUB_API}/win32_registry-1.1.3.tar.gz \
	${PUB_API}/xdg_directories-1.0.4.tar.gz \
	${PUB_API}/xml-6.5.0.tar.gz \
	${PUB_API}/yaml-3.1.2.tar.gz \
	 \
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="!app-misc/maid-appimage x11-libs/gtk+:3 x11-libs/pango"
BDEPEND="dev-lang/flutter-bin dev-build/ninja dev-build/cmake virtual/pkgconfig dev-vcs/git"


src_unpack() {
	unpack ${P}.tar.gz
	export PUB_CACHE="${WORKDIR}/pub-cache"
	mkdir -p "${PUB_CACHE}/hosted/pub.dev"

	for file in ${A}; do
		if [[ ${file} != ${P}.tar.gz ]]; then
			pkg_ver=${file%.tar.gz}
			mkdir -p "${PUB_CACHE}/hosted/pub.dev/${pkg_ver}"
			tar -xzf "${DISTDIR}/${file}" \
				-C "${PUB_CACHE}/hosted/pub.dev/${pkg_ver}"
		fi
	done
}

src_prepare() {
	default
}

src_compile() {
	flutter config --no-analytics || die
	export PUB_CACHE="${WORKDIR}/pub-cache"
	flutter pub get --offline || die
	export PUB_CACHE="${WORKDIR}/pub-cache"
	flutter build linux --no-pub || die
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
