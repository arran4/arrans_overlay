# Copyright 2024 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="A Flutter-based app for interacting with the Google Jules API"
LICENSE="MIT"
HOMEPAGE="https://github.com/arran4/flutter_jules"
PUB="pub.dev/api/archives"
JULES_SRC="github.com/arran4/flutter_jules/archive/refs/tags"
FLUTTER_PV="3.47.2"
FLUTTER_ENGINE_COMMIT="a804b261645ef8c13eb3d5c44a5c2fb0340c5539"
GCS="storage.googleapis.com/flutter_infra_release/flutter"
FLUTTER_STORAGE="${GCS}/${FLUTTER_ENGINE_COMMIT}"
SRC_URI="https://${JULES_SRC}/v${PV}.tar.gz -> flutter-jules-${PV}.tar.gz \
	https://${FLUTTER_STORAGE}/linux-x64-debug/linux-x64-flutter-gtk.zip
		-> flutter-linux-x64-debug-${FLUTTER_ENGINE_COMMIT}.zip \
	https://${FLUTTER_STORAGE}/linux-x64-profile/linux-x64-flutter-gtk.zip
		-> flutter-linux-x64-profile-${FLUTTER_ENGINE_COMMIT}.zip \
	https://${FLUTTER_STORAGE}/linux-x64-release/linux-x64-flutter-gtk.zip
		-> flutter-linux-x64-release-${FLUTTER_ENGINE_COMMIT}.zip \
	https://${PUB}/_fe_analyzer_shared-92.0.0.tar.gz \
	https://${PUB}/analyzer-9.0.0.tar.gz \
	https://${PUB}/archive-4.0.7.tar.gz \
	https://${PUB}/args-2.7.0.tar.gz \
	https://${PUB}/async-2.13.0.tar.gz \
	https://${PUB}/boolean_selector-2.1.2.tar.gz \
	https://${PUB}/build-4.0.3.tar.gz \
	https://${PUB}/build_config-1.2.0.tar.gz \
	https://${PUB}/build_daemon-4.1.1.tar.gz \
	https://${PUB}/build_runner-2.10.4.tar.gz \
	https://${PUB}/built_collection-5.1.1.tar.gz \
	https://${PUB}/built_value-8.12.1.tar.gz \
	https://${PUB}/characters-1.4.1.tar.gz \
	https://${PUB}/checked_yaml-2.0.4.tar.gz \
	https://${PUB}/cli_util-0.4.2.tar.gz \
	https://${PUB}/clock-1.1.2.tar.gz \
	https://${PUB}/code_builder-4.11.0.tar.gz \
	https://${PUB}/collection-1.19.1.tar.gz \
	https://${PUB}/convert-3.1.2.tar.gz \
	https://${PUB}/cross_file-0.3.5+1.tar.gz \
	https://${PUB}/crypto-3.0.7.tar.gz \
	https://${PUB}/dart_style-3.1.3.tar.gz \
	https://${PUB}/dartobjectutils-0.1.1.tar.gz \
	https://${PUB}/dbus-0.7.11.tar.gz \
	https://${PUB}/desktop_multi_window-0.2.1.tar.gz \
	https://${PUB}/duration-4.0.3.tar.gz \
	https://${PUB}/fake_async-1.3.3.tar.gz \
	https://${PUB}/ffi-2.1.4.tar.gz \
	https://${PUB}/file-7.0.1.tar.gz \
	https://${PUB}/file_selector-1.1.0.tar.gz \
	https://${PUB}/file_selector_android-0.5.2+4.tar.gz \
	https://${PUB}/file_selector_ios-0.5.3+5.tar.gz \
	https://${PUB}/file_selector_linux-0.9.4.tar.gz \
	https://${PUB}/file_selector_macos-0.9.5.tar.gz \
	https://${PUB}/file_selector_platform_interface-2.7.0.tar.gz \
	https://${PUB}/file_selector_web-0.9.4+2.tar.gz \
	https://${PUB}/file_selector_windows-0.9.3+5.tar.gz \
	https://${PUB}/fixnum-1.1.1.tar.gz \
	https://${PUB}/flutter_launcher_icons-0.13.1.tar.gz \
	https://${PUB}/flutter_lints-2.0.3.tar.gz \
	https://${PUB}/flutter_local_notifications-17.2.4.tar.gz \
	https://${PUB}/flutter_local_notifications_linux-4.0.1.tar.gz \
	https://${PUB}/flutter_local_notifications_platform_interface-7.2.0.tar.gz \
	https://${PUB}/flutter_markdown-0.7.7+1.tar.gz \
	https://${PUB}/flutter_secure_storage-9.2.4.tar.gz \
	https://${PUB}/flutter_secure_storage_linux-1.2.3.tar.gz \
	https://${PUB}/flutter_secure_storage_macos-3.1.3.tar.gz \
	https://${PUB}/flutter_secure_storage_platform_interface-1.1.2.tar.gz \
	https://${PUB}/flutter_secure_storage_web-1.2.1.tar.gz \
	https://${PUB}/flutter_secure_storage_windows-3.1.2.tar.gz \
	https://${PUB}/glob-2.1.3.tar.gz \
	https://${PUB}/google_identity_services_web-0.3.3+1.tar.gz \
	https://${PUB}/google_sign_in-6.3.0.tar.gz \
	https://${PUB}/google_sign_in_android-6.2.1.tar.gz \
	https://${PUB}/google_sign_in_ios-5.9.0.tar.gz \
	https://${PUB}/google_sign_in_platform_interface-2.5.0.tar.gz \
	https://${PUB}/google_sign_in_web-0.12.4+4.tar.gz \
	https://${PUB}/graphs-2.3.2.tar.gz \
	https://${PUB}/http-1.6.0.tar.gz \
	https://${PUB}/http_multi_server-3.2.2.tar.gz \
	https://${PUB}/http_parser-4.1.2.tar.gz \
	https://${PUB}/image-4.7.2.tar.gz \
	https://${PUB}/intl-0.18.1.tar.gz \
	https://${PUB}/io-1.0.5.tar.gz \
	https://${PUB}/js-0.6.7.tar.gz \
	https://${PUB}/json_annotation-4.9.0.tar.gz \
	https://${PUB}/leak_tracker-11.0.2.tar.gz \
	https://${PUB}/leak_tracker_flutter_testing-3.0.10.tar.gz \
	https://${PUB}/leak_tracker_testing-3.0.2.tar.gz \
	https://${PUB}/lints-2.1.1.tar.gz \
	https://${PUB}/logging-1.3.0.tar.gz \
	https://${PUB}/markdown-7.3.0.tar.gz \
	https://${PUB}/matcher-0.12.20.tar.gz \
	https://${PUB}/material_color_utilities-0.13.0.tar.gz \
	https://${PUB}/menu_base-0.1.1.tar.gz \
	https://${PUB}/meta-1.19.0.tar.gz \
	https://${PUB}/mime-2.0.0.tar.gz \
	https://${PUB}/mockito-5.6.1.tar.gz \
	https://${PUB}/nested-1.0.0.tar.gz \
	https://${PUB}/package_config-2.2.0.tar.gz \
	https://${PUB}/pasteboard-0.4.0.tar.gz \
	https://${PUB}/path-1.9.1.tar.gz \
	https://${PUB}/path_provider-2.1.5.tar.gz \
	https://${PUB}/path_provider_android-2.2.22.tar.gz \
	https://${PUB}/path_provider_foundation-2.5.1.tar.gz \
	https://${PUB}/path_provider_linux-2.2.1.tar.gz \
	https://${PUB}/path_provider_platform_interface-2.1.2.tar.gz \
	https://${PUB}/path_provider_windows-2.3.0.tar.gz \
	https://${PUB}/petitparser-7.0.1.tar.gz \
	https://${PUB}/platform-3.1.6.tar.gz \
	https://${PUB}/plugin_platform_interface-2.1.8.tar.gz \
	https://${PUB}/pool-1.5.2.tar.gz \
	https://${PUB}/posix-6.0.3.tar.gz \
	https://${PUB}/provider-6.1.5+1.tar.gz \
	https://${PUB}/pub_semver-2.2.0.tar.gz \
	https://${PUB}/pubspec_parse-1.5.0.tar.gz \
	https://${PUB}/screen_retriever-0.1.9.tar.gz \
	https://${PUB}/shared_preferences-2.5.4.tar.gz \
	https://${PUB}/shared_preferences_android-2.4.18.tar.gz \
	https://${PUB}/shared_preferences_foundation-2.5.6.tar.gz \
	https://${PUB}/shared_preferences_linux-2.4.1.tar.gz \
	https://${PUB}/shared_preferences_platform_interface-2.4.1.tar.gz \
	https://${PUB}/shared_preferences_web-2.4.3.tar.gz \
	https://${PUB}/shared_preferences_windows-2.4.1.tar.gz \
	https://${PUB}/shelf-1.4.2.tar.gz \
	https://${PUB}/shelf_web_socket-3.0.0.tar.gz \
	https://${PUB}/shortid-0.1.2.tar.gz \
	https://${PUB}/source_gen-4.1.1.tar.gz \
	https://${PUB}/source_span-1.10.1.tar.gz \
	https://${PUB}/stack_trace-1.12.1.tar.gz \
	https://${PUB}/stream_channel-2.1.4.tar.gz \
	https://${PUB}/stream_transform-2.1.1.tar.gz \
	https://${PUB}/string_scanner-1.4.1.tar.gz \
	https://${PUB}/term_glyph-1.2.2.tar.gz \
	https://${PUB}/test_api-0.7.12.tar.gz \
	https://${PUB}/timezone-0.9.4.tar.gz \
	https://${PUB}/tray_manager-0.2.4.tar.gz \
	https://${PUB}/typed_data-1.4.0.tar.gz \
	https://${PUB}/url_launcher-6.3.2.tar.gz \
	https://${PUB}/url_launcher_android-6.3.28.tar.gz \
	https://${PUB}/url_launcher_ios-6.3.6.tar.gz \
	https://${PUB}/url_launcher_linux-3.2.2.tar.gz \
	https://${PUB}/url_launcher_macos-3.2.5.tar.gz \
	https://${PUB}/url_launcher_platform_interface-2.3.2.tar.gz \
	https://${PUB}/url_launcher_web-2.4.1.tar.gz \
	https://${PUB}/url_launcher_windows-3.1.5.tar.gz \
	https://${PUB}/uuid-4.5.2.tar.gz \
	https://${PUB}/vector_math-2.4.2.tar.gz \
	https://${PUB}/vm_service-15.0.2.tar.gz \
	https://${PUB}/watcher-1.2.0.tar.gz \
	https://${PUB}/web-1.1.1.tar.gz \
	https://${PUB}/web_socket-1.0.1.tar.gz \
	https://${PUB}/web_socket_channel-3.0.3.tar.gz \
	https://${PUB}/win32-5.15.0.tar.gz \
	https://${PUB}/window_manager-0.3.9.tar.gz \
	https://${PUB}/xdg_directories-1.1.0.tar.gz \
	https://${PUB}/xml-6.6.1.tar.gz \
	https://${PUB}/yaml-3.1.3.tar.gz"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}/${PN/-/_}-${PV}"

COMMON_DEPEND="
	app-crypt/libsecret
	dev-libs/libayatana-appindicator
	x11-libs/gtk+:3
	x11-libs/pango
"
RDEPEND="
	${COMMON_DEPEND}
	!app-misc/flutter-jules-bin
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	=dev-lang/flutter-bin-${FLUTTER_PV}*
	app-arch/unzip
	dev-build/ninja
	dev-build/cmake
	llvm-core/clang
	virtual/pkgconfig
"

src_unpack() {
	local file pkg_ver
	local pub_cache="${WORKDIR}/pub-cache"

	unpack "${P}.tar.gz"
	mkdir -p "${pub_cache}/hosted/pub.dev" || die

	for file in ${A}; do
		if [[ ${file} == *.tar.gz && ${file} != ${P}.tar.gz ]]; then
			pkg_ver=${file%.tar.gz}
			local dest="${pub_cache}/hosted/pub.dev/${pkg_ver}"
			mkdir -p "${dest}" || die
			tar -xzf "${DISTDIR}/${file}" -C "${dest}" || die
		fi
	done
}

src_compile() {
	local mode dir

	if ! command -v clang++ >/dev/null 2>&1; then
		local llvm_bin
		for llvm_bin in $(ls -d "${BROOT}"/usr/lib/llvm/*/bin \
			2>/dev/null | sort -V -r); do
			if [[ -x "${llvm_bin}/clang++" ]]; then
				export PATH="${llvm_bin}:${PATH}"
				break
			fi
		done
	fi
	command -v clang++ >/dev/null 2>&1 || die "clang++ not found in PATH"

	export FLUTTER_CACHE_DIR="${WORKDIR}/flutter-cache"
	export PUB_CACHE="${WORKDIR}/pub-cache"
	mkdir -p "${FLUTTER_CACHE_DIR}" || die
	cp -a --reflink=auto /opt/flutter/bin/cache/. \
		"${FLUTTER_CACHE_DIR}/" || die
	chmod -R u+rwX "${FLUTTER_CACHE_DIR}" || die
	for mode in debug profile release; do
		if [[ ${mode} == "debug" ]]; then
			dir="linux-x64"
		else
			dir="linux-x64-${mode}"
		fi
		local eng_dir="${FLUTTER_CACHE_DIR}/artifacts/engine/${dir}"
		local eng_zip="flutter-linux-x64-${mode}"
		eng_zip+="-${FLUTTER_ENGINE_COMMIT}.zip"
		mkdir -p "${eng_dir}" || die
		unzip -qo "${DISTDIR}/${eng_zip}" -d "${eng_dir}" || die
	done
	printf '%s\n' "${FLUTTER_ENGINE_COMMIT}" \
		> "${FLUTTER_CACHE_DIR}/linux-sdk.stamp" || die

	mkdir -p build/native_assets/linux || die

	flutter config --no-analytics || die
	flutter pub get --offline || die
	flutter build linux --release --no-pub || die
}

src_install() {
	insinto /opt/flutter_jules
	doins -r build/linux/x64/release/bundle/*
	fperms +x /opt/flutter_jules/flutter_jules
	dosym ../../opt/flutter_jules/flutter_jules /usr/bin/flutter_jules

	local icon="macos/Runner/Assets.xcassets"
	icon+="/AppIcon.appiconset/app_icon_1024.png"
	newicon -s 1024 "${icon}" com.arran4.flutter_jules.png
	domenu linux/com.arran4.flutter_jules.desktop
}
