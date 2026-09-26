#!/usr/bin/env python3
"""Regenerate the pinned Flutter tooling pub dependencies in the ebuild.

Flutter tools require a fixed graph of pub packages to build
flutter_tools.snapshot and operate offline without contacting pub.dev.
This generator synchronizes the declared pub dependencies and artifacts
with the Flutter 3.47.2 ebuild.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

FLUTTER_VERSION = "3.47.2"
FLUTTER_ENGINE_REV = "a804b261645ef8c13eb3d5c44a5c2fb0340c5539"
MATERIAL_FONTS_REV = "3012db47f3130e62f7cc0beabff968a33cbec8d8"
GRADLE_WRAPPER_REV = "fd5c1f2c013565a3bea56ada6df9d2b8e96d56aa"

EBUILD = (
	Path(__file__).parents[1]
	/ "dev-lang"
	/ "flutter"
	/ f"flutter-{FLUTTER_VERSION}.ebuild"
)
BEGIN = "# BEGIN GENERATED FLUTTER PUB DEPS"
END = "# END GENERATED FLUTTER PUB DEPS"

# The 101 pinned pub packages required for packages/flutter_tools in Flutter 3.47.2.
# Every dependency is pinned to an exact version for deterministic offline builds.
PUB_DEPENDENCIES: dict[str, str] = {
	"_fe_analyzer_shared": "95.0.0",
	"analyzer": "10.1.0",
	"archive": "3.6.1",
	"args": "2.7.0",
	"async": "2.13.1",
	"boolean_selector": "2.1.2",
	"browser_launcher": "1.1.3",
	"built_collection": "5.1.1",
	"built_value": "8.12.6",
	"checked_yaml": "2.0.4",
	"cli_config": "0.2.0",
	"clock": "1.1.2",
	"code_assets": "1.2.1",
	"code_builder": "4.11.1",
	"collection": "1.19.1",
	"completion": "1.0.2",
	"convert": "3.1.2",
	"coverage": "1.15.1",
	"crypto": "3.0.7",
	"csslib": "1.0.2",
	"dap": "1.4.0",
	"dart_service_protocol_shared": "0.0.3",
	"dart_style": "3.1.7",
	"data_assets": "0.20.0",
	"dds": "5.3.0",
	"dds_service_extensions": "2.1.0",
	"devtools_shared": "12.1.0",
	"dtd": "4.0.0",
	"dwds": "27.1.2",
	"extension_discovery": "2.1.0",
	"fake_async": "1.3.3",
	"ffi": "2.2.0",
	"file": "7.0.1",
	"file_testing": "3.0.2",
	"fixnum": "1.1.1",
	"flutter_template_images": "5.0.0",
	"frontend_server_client": "4.0.0",
	"glob": "2.1.3",
	"graphs": "2.3.2",
	"hooks": "2.0.2",
	"hooks_runner": "1.5.0",
	"html": "0.15.6",
	"http": "1.6.0",
	"http_multi_server": "3.2.2",
	"http_parser": "4.1.2",
	"intl": "0.20.3",
	"io": "1.0.5",
	"js": "0.7.2",
	"json_annotation": "4.12.0",
	"json_rpc_2": "4.1.0",
	"logging": "1.3.0",
	"matcher": "0.12.20",
	"meta": "1.18.3",
	"mime": "2.0.0",
	"multicast_dns": "0.3.3+1",
	"mustache_template": "2.0.5",
	"native_stack_traces": "0.6.1",
	"node_preamble": "2.0.2",
	"package_config": "2.2.0",
	"path": "1.9.1",
	"petitparser": "7.0.2",
	"platform": "3.1.6",
	"pool": "1.5.2",
	"process": "5.0.5",
	"pub_semver": "2.2.0",
	"pubspec_parse": "1.5.0",
	"record_use": "0.6.0",
	"shelf": "1.4.2",
	"shelf_packages_handler": "3.0.2",
	"shelf_proxy": "1.0.5",
	"shelf_static": "1.1.3",
	"shelf_web_socket": "3.0.0",
	"source_map_stack_trace": "2.1.2",
	"source_maps": "0.10.13",
	"source_span": "1.10.2",
	"sprintf": "7.0.0",
	"sse": "4.2.0",
	"stack_trace": "1.12.1",
	"standard_message_codec": "0.0.1+5",
	"stream_channel": "2.1.4",
	"string_scanner": "1.4.1",
	"sync_http": "0.3.1",
	"term_glyph": "1.2.2",
	"test": "1.31.1",
	"test_api": "0.7.12",
	"test_core": "0.6.18",
	"typed_data": "1.4.0",
	"unified_analytics": "8.0.15",
	"uuid": "4.5.3",
	"vm_service": "15.2.0",
	"vm_service_interface": "2.0.1",
	"vm_snapshot_analysis": "0.7.6",
	"watcher": "1.2.1",
	"web": "1.1.1",
	"web_socket": "1.0.1",
	"web_socket_channel": "3.0.3",
	"webdriver": "3.1.0",
	"webkit_inspection_protocol": "1.2.1",
	"xml": "6.6.1",
	"yaml": "3.1.3",
	"yaml_edit": "2.2.4",
}


def render_pub_deps(deps: dict[str, str] = PUB_DEPENDENCIES) -> str:
	lines: list[str] = [
		BEGIN,
		f'FLUTTER_FONTS_REV="{MATERIAL_FONTS_REV}"',
		f'FLUTTER_GRADLE_REV="{GRADLE_WRAPPER_REV}"',
		'FLUTTER_GCS="https://storage.googleapis.com/flutter_infra_release"',
		'PUB_URI="https://pub.dev/api/archives"',
		'SRC_URI="',
	]
	lines.append("\thttps://github.com/flutter/flutter/archive/refs/tags/${PV}.tar.gz")
	lines.append("\t\t-> ${P}.tar.gz")
	lines.append(
		"\t${FLUTTER_GCS}/flutter/fonts/${FLUTTER_FONTS_REV}/fonts.zip"
	)
	lines.append("\t\t-> flutter-material-fonts-3012db47.zip")
	lines.append(
		"\t${FLUTTER_GCS}/gradle-wrapper/${FLUTTER_GRADLE_REV}/gradle-wrapper.tgz"
	)
	lines.append("\t\t-> flutter-gradle-wrapper-fd5c1f2c.tgz")

	for pkg, ver in sorted(deps.items()):
		lines.append(f"\t${{PUB_URI}}/{pkg}-{ver}.tar.gz")

	lines.extend(['"', END])

	too_long = [
		(index, line)
		for index, line in enumerate(lines, 1)
		if len(line.expandtabs(4)) > 100
	]
	if too_long:
		raise ValueError(f"generated lines exceed 100 columns: {too_long}")
	return "\n".join(lines)


def update_ebuild(ebuild_path: Path, generated: str, check: bool) -> int:
	existing = ebuild_path.read_text()
	pattern = re.compile(
		rf"^{re.escape(BEGIN)}$.*?^{re.escape(END)}$",
		re.MULTILINE | re.DOTALL,
	)
	replacement, count = pattern.subn(generated, existing)
	if count != 1:
		raise ValueError(
			f"expected one generated block in {ebuild_path}, found {count}"
		)
	if replacement == existing:
		return 0
	if check:
		print(
			f"{ebuild_path} is not synchronized with Flutter {FLUTTER_VERSION} pub dependencies",
			file=sys.stderr,
		)
		return 1
	ebuild_path.write_text(replacement)
	return 0


def main() -> int:
	parser = argparse.ArgumentParser()
	parser.add_argument("--check", action="store_true")
	parser.add_argument("--ebuild", type=Path, default=EBUILD)
	args = parser.parse_args()
	return update_ebuild(args.ebuild, render_pub_deps(), args.check)


if __name__ == "__main__":
	raise SystemExit(main())
