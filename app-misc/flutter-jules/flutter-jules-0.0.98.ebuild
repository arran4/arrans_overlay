# Copyright 2024 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="A Flutter-based app for interacting with the Google Jules API"
HOMEPAGE="https://github.com/arran4/flutter_jules"
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
JULES_GH="Desktop-Artificial-Intelligence"
SRC_URI="https://github.com/arran4/flutter_jules/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz \
	${PUB_API}/_fe_analyzer_shared-92.0.0.tar.gz \
	${PUB_API}/analyzer-9.0.0.tar.gz \
	${PUB_API}/archive-4.0.7.tar.gz \
	${PUB_API}/args-2.7.0.tar.gz \
	${PUB_API}/async-2.13.0.tar.gz \
	${PUB_API}/boolean_selector-2.1.2.tar.gz \
	${PUB_API}/build-4.0.3.tar.gz \
	${PUB_API}/build_config-1.2.0.tar.gz \
	${PUB_API}/build_daemon-4.1.1.tar.gz \
	${PUB_API}/build_runner-2.10.4.tar.gz \
	${PUB_API}/built_collection-5.1.1.tar.gz \
	${PUB_API}/built_value-8.12.1.tar.gz \
	${PUB_API}/characters-1.4.0.tar.gz \
	${PUB_API}/checked_yaml-2.0.4.tar.gz \
	${PUB_API}/cli_util-0.4.2.tar.gz \
	${PUB_API}/clock-1.1.2.tar.gz \
	${PUB_API}/code_builder-4.11.0.tar.gz \
	${PUB_API}/collection-1.19.1.tar.gz \
	${PUB_API}/convert-3.1.2.tar.gz \
	${PUB_API}/cross_file-0.3.5+1.tar.gz \
	${PUB_API}/crypto-3.0.7.tar.gz \
	${PUB_API}/dart_style-3.1.3.tar.gz \
	${PUB_API}/dartobjectutils-0.1.1.tar.gz \
	${PUB_API}/dbus-0.7.11.tar.gz \
	${PUB_API}/desktop_multi_window-0.2.1.tar.gz \
	${PUB_API}/duration-4.0.3.tar.gz \
	${PUB_API}/fake_async-1.3.3.tar.gz \
	${PUB_API}/ffi-2.1.4.tar.gz \
	${PUB_API}/file-7.0.1.tar.gz \
	${PUB_API}/file_selector-1.1.0.tar.gz \
	${PUB_API}/file_selector_android-0.5.2+4.tar.gz \
	${PUB_API}/file_selector_ios-0.5.3+5.tar.gz \
	${PUB_API}/file_selector_linux-0.9.4.tar.gz \
	${PUB_API}/file_selector_macos-0.9.5.tar.gz \
	${PUB_API}/file_selector_platform_interface-2.7.0.tar.gz \
	${PUB_API}/file_selector_web-0.9.4+2.tar.gz \
	${PUB_API}/file_selector_windows-0.9.3+5.tar.gz \
	${PUB_API}/fixnum-1.1.1.tar.gz \
	${PUB_API}/flutter_launcher_icons-0.13.1.tar.gz \
	${PUB_API}/flutter_lints-2.0.3.tar.gz \
	${PUB_API}/flutter_local_notifications-17.2.4.tar.gz \
	${PUB_API}/flutter_local_notifications_linux-4.0.1.tar.gz \
	${PUB_API}/flutter_local_notifications_platform_interface-7.2.0.tar.gz \
	${PUB_API}/flutter_markdown-0.7.7+1.tar.gz \
	${PUB_API}/flutter_secure_storage-9.2.4.tar.gz \
	${PUB_API}/flutter_secure_storage_linux-1.2.3.tar.gz \
	${PUB_API}/flutter_secure_storage_macos-3.1.3.tar.gz \
	${PUB_API}/flutter_secure_storage_platform_interface-1.1.2.tar.gz \
	${PUB_API}/flutter_secure_storage_web-1.2.1.tar.gz \
	${PUB_API}/flutter_secure_storage_windows-3.1.2.tar.gz \
	${PUB_API}/glob-2.1.3.tar.gz \
	${PUB_API}/google_identity_services_web-0.3.3+1.tar.gz \
	${PUB_API}/google_sign_in-6.3.0.tar.gz \
	${PUB_API}/google_sign_in_android-6.2.1.tar.gz \
	${PUB_API}/google_sign_in_ios-5.9.0.tar.gz \
	${PUB_API}/google_sign_in_platform_interface-2.5.0.tar.gz \
	${PUB_API}/google_sign_in_web-0.12.4+4.tar.gz \
	${PUB_API}/graphs-2.3.2.tar.gz \
	${PUB_API}/http-1.6.0.tar.gz \
	-> http-1.6.0.tar.gz \
	${PUB_API}/http_multi_server-3.2.2.tar.gz \
	-> http_multi_server-3.2.2.tar.gz \
	${PUB_API}/http_parser-4.1.2.tar.gz \
	-> http_parser-4.1.2.tar.gz \
	${PUB_API}/image-4.7.2.tar.gz \
	${PUB_API}/intl-0.18.1.tar.gz \
	${PUB_API}/io-1.0.5.tar.gz \
	${PUB_API}/js-0.6.7.tar.gz \
	${PUB_API}/json_annotation-4.9.0.tar.gz \
	${PUB_API}/${LTRACKER}-11.0.2.tar.gz \
	${PUB_API}/${LTRACKER_F}-3.0.10.tar.gz \
	${PUB_API}/${LTRACKER_T}-3.0.2.tar.gz \
	${PUB_API}/lints-2.1.1.tar.gz \
	${PUB_API}/logging-1.3.0.tar.gz \
	${PUB_API}/markdown-7.3.0.tar.gz \
	${PUB_API}/matcher-0.12.17.tar.gz \
	${PUB_API}/material_color_utilities-0.11.1.tar.gz \
	${PUB_API}/menu_base-0.1.1.tar.gz \
	${PUB_API}/meta-1.17.0.tar.gz \
	${PUB_API}/mime-2.0.0.tar.gz \
	${PUB_API}/mockito-5.6.1.tar.gz \
	${PUB_API}/nested-1.0.0.tar.gz \
	${PUB_API}/package_config-2.2.0.tar.gz \
	${PUB_API}/pasteboard-0.4.0.tar.gz \
	${PUB_API}/path-1.9.1.tar.gz \
	${PUB_API}/path_provider-2.1.5.tar.gz \
	${PUB_API}/path_provider_android-2.2.22.tar.gz \
	${PUB_API}/path_provider_foundation-2.5.1.tar.gz \
	${PUB_API}/path_provider_linux-2.2.1.tar.gz \
	${PUB_API}/${PATH_PROV}-2.1.2.tar.gz \
	${PUB_API}/path_provider_windows-2.3.0.tar.gz \
	${PUB_API}/petitparser-7.0.1.tar.gz \
	${PUB_API}/platform-3.1.6.tar.gz \
	${PUB_API}/plugin_platform_interface-2.1.8.tar.gz \
	${PUB_API}/pool-1.5.2.tar.gz \
	${PUB_API}/posix-6.0.3.tar.gz \
	${PUB_API}/provider-6.1.5+1.tar.gz \
	${PUB_API}/pub_semver-2.2.0.tar.gz \
	${PUB_API}/pubspec_parse-1.5.0.tar.gz \
	${PUB_API}/screen_retriever-0.1.9.tar.gz \
	${PUB_API}/shared_preferences-2.5.4.tar.gz \
	${PUB_API}/shared_preferences_android-2.4.18.tar.gz \
	${PUB_API}/shared_preferences_foundation-2.5.6.tar.gz \
	${PUB_API}/shared_preferences_linux-2.4.1.tar.gz \
	${PUB_API}/${PREFS_PI}-2.4.1.tar.gz \
	${PUB_API}/shared_preferences_web-2.4.3.tar.gz \
	${PUB_API}/shared_preferences_windows-2.4.1.tar.gz \
	${PUB_API}/shelf-1.4.2.tar.gz \
	${PUB_API}/shelf_web_socket-3.0.0.tar.gz \
	${PUB_API}/shortid-0.1.2.tar.gz \
	${PUB_API}/source_gen-4.1.1.tar.gz \
	${PUB_API}/source_span-1.10.1.tar.gz \
	${PUB_API}/stack_trace-1.12.1.tar.gz \
	${PUB_API}/stream_channel-2.1.4.tar.gz \
	${PUB_API}/stream_transform-2.1.1.tar.gz \
	${PUB_API}/string_scanner-1.4.1.tar.gz \
	${PUB_API}/term_glyph-1.2.2.tar.gz \
	${PUB_API}/test_api-0.7.7.tar.gz \
	${PUB_API}/timezone-0.9.4.tar.gz \
	${PUB_API}/tray_manager-0.2.4.tar.gz \
	${PUB_API}/typed_data-1.4.0.tar.gz \
	${PUB_API}/url_launcher-6.3.2.tar.gz \
	${PUB_API}/url_launcher_android-6.3.28.tar.gz \
	${PUB_API}/url_launcher_ios-6.3.6.tar.gz \
	${PUB_API}/url_launcher_linux-3.2.2.tar.gz \
	${PUB_API}/url_launcher_macos-3.2.5.tar.gz \
	${PUB_API}/url_launcher_platform_interface-2.3.2.tar.gz \
	${PUB_API}/url_launcher_web-2.4.1.tar.gz \
	${PUB_API}/url_launcher_windows-3.1.5.tar.gz \
	${PUB_API}/uuid-4.5.2.tar.gz \
	${PUB_API}/vector_math-2.2.0.tar.gz \
	${PUB_API}/vm_service-15.0.2.tar.gz \
	${PUB_API}/watcher-1.2.0.tar.gz \
	${PUB_API}/web-1.1.1.tar.gz \
	${PUB_API}/web_socket-1.0.1.tar.gz \
	${PUB_API}/web_socket_channel-3.0.3.tar.gz \
	${PUB_API}/win32-5.15.0.tar.gz \
	${PUB_API}/window_manager-0.3.9.tar.gz \
	${PUB_API}/xdg_directories-1.1.0.tar.gz \
	${PUB_API}/xml-6.6.1.tar.gz \
	${PUB_API}/yaml-3.1.3.tar.gz \
	 \
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}/${PN/-/_}-${PV}"

RDEPEND="!app-misc/flutter-jules-bin x11-libs/gtk+:3 x11-libs/pango"
BDEPEND="dev-lang/flutter-bin dev-build/ninja dev-build/cmake virtual/pkgconfig"


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

src_compile() {
	flutter config --no-analytics || die
	export PUB_CACHE="${WORKDIR}/pub-cache"
	flutter pub get --offline || die
	export PUB_CACHE="${WORKDIR}/pub-cache"
	flutter build linux --no-pub || die
}

src_install() {
	insinto /opt/flutter_jules
	doins -r build/linux/x64/release/bundle/*
	fperms +x /opt/flutter_jules/flutter_jules
	dosym ../../opt/flutter_jules/flutter_jules /usr/bin/flutter_jules

	# Install desktop file and icon
	doicon -s 256 assets/logo.png
	make_desktop_entry flutter_jules "Flutter Jules" logo Utility
}
