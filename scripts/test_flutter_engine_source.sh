#!/bin/bash
set -Eeuo pipefail

# Build and smoke-test Flutter Engine from source in an offline container.
#
# Usage: scripts/test_flutter_engine_source.sh [--distfiles DIR]
#
# The host needs Docker and network access during preparation. The script
# disconnects the test container before emerging dev-libs/flutter-engine.

usage() {
	cat <<'HELP'
Usage: scripts/test_flutter_engine_source.sh [options]

Options:
  --distfiles DIR    Persistent host directory for downloaded distfiles
  --binpkgs DIR      Persistent host directory for binary packages
  --keep-containers  Leave the test containers behind for inspection
  -h, --help         Show this help

Environment overrides:
  FLUTTER_ENGINE_SOURCE_ATOM, DART_VIRTUAL_ATOM, FLUTTER_ENGINE_BINPKGS
HELP
}

repo_root=$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
cache_root=${XDG_CACHE_HOME:-${HOME}/.cache}
default_dist="${cache_root}/arrans-overlay/flutter-distfiles"
distfiles=${FLUTTER_ENGINE_DISTDIR:-${default_dist}}
default_binpkgs="${cache_root}/arrans-overlay/binpkgs"
binpkgs=${FLUTTER_ENGINE_BINPKGS:-${PKGDIR:-${default_binpkgs}}}
keep_containers=false

while [[ $# -gt 0 ]]; do
	case $1 in
		--distfiles)
			[[ $# -ge 2 ]] || {
				echo "--distfiles requires a directory" >&2
				exit 2
			}
			distfiles=$2
			shift 2
			;;
		--binpkgs)
			[[ $# -ge 2 ]] || {
				echo "--binpkgs requires a directory" >&2
				exit 2
			}
			binpkgs=$2
			shift 2
			;;
		--keep-containers)
			keep_containers=true
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			usage >&2
			exit 2
			;;
	esac
done

command -v docker >/dev/null || {
	echo "Docker is required for Flutter Engine integration test" >&2
	exit 1
}

mkdir -p "${distfiles}" "${binpkgs}"
distfiles=$(cd "${distfiles}" && pwd -P)
binpkgs=$(cd "${binpkgs}" && pwd -P)

source_atom=${FLUTTER_ENGINE_SOURCE_ATOM:-=dev-libs/flutter-engine-3.47.2}
virtual_atom=${DART_VIRTUAL_ATOM:-=virtual/dart-3.13.3-r1}
container_suffix="${UID:-0}-$$"
portage_container="flutter-engine-portage-${container_suffix}"
gentoo_container="flutter-engine-gentoo-${container_suffix}"
guru_tmp=$(mktemp -d --tmpdir guru-repo-XXXXXX)

cleanup() {
	local status=$?
	trap - EXIT
	if ${keep_containers}; then
		echo "Keeping containers:" \
			"${gentoo_container} and ${portage_container}"
	else
		docker rm --force \
			"${gentoo_container}" "${portage_container}" \
			>/dev/null 2>&1 || true
	fi
	rm -rf "${guru_tmp}"
	exit "${status}"
}
trap cleanup EXIT

echo "Fetching GURU overlay for games-util/libtess2"
git clone --depth=1 https://github.com/gentoo-mirror/guru.git "${guru_tmp}"
chmod -R a+rX "${guru_tmp}"

echo "Pulling Gentoo stage3 and Portage images"
docker pull gentoo/stage3:latest
docker pull gentoo/portage:latest

docker create --name "${portage_container}" gentoo/portage:latest >/dev/null
docker run --detach \
	--name "${gentoo_container}" \
	--volumes-from "${portage_container}" \
	--volume "${repo_root}:/var/db/repos/arrans-overlay:ro" \
	--volume "${guru_tmp}:/var/db/repos/guru:ro" \
	--volume "${distfiles}:/var/cache/distfiles:rw" \
	--volume "${binpkgs}:/var/cache/binpkgs:rw" \
	gentoo/stage3:latest \
	sleep infinity >/dev/null

echo "Preparing toolchain, dependencies, and distfiles online"
docker exec -i "${gentoo_container}" bash -euxo pipefail -s -- \
	"${source_atom}" "${virtual_atom}" <<'ONLINE'
source_atom=$1
virtual_atom=$2

chmod 777 /var/cache/distfiles /var/cache/binpkgs
mkdir -p /etc/portage/repos.conf
printf '%s\n' \
	'[gentoo]' \
	'location = /var/db/repos/gentoo' \
	'auto-sync = no' \
	> /etc/portage/repos.conf/gentoo.conf
printf '%s\n' \
	'[guru]' \
	'location = /var/db/repos/guru' \
	'auto-sync = no' \
	> /etc/portage/repos.conf/guru.conf
printf '%s\n' \
	'[arrans-overlay]' \
	'location = /var/db/repos/arrans-overlay' \
	'masters = gentoo guru' \
	'auto-sync = no' \
	> /etc/portage/repos.conf/arrans-overlay.conf

printf '%s\n' \
	'ACCEPT_LICENSE="*"' \
	'FEATURES="${FEATURES} buildpkg"' \
	'CONFIG_PROTECT_MASK="${CONFIG_PROTECT_MASK} ' \
	'/etc/portage/package.accept_keywords /etc/portage/package.use"' \
	>> /etc/portage/make.conf

mkdir -p /etc/portage/package.accept_keywords
printf '%s ~amd64\n' \
	"${source_atom}" \
	"${virtual_atom}" \
	'dev-lang/dart-bin' \
	'dev-lang/dart' \
	'games-util/libtess2' \
	> /etc/portage/package.accept_keywords/flutter-engine-test

# GCC with C++ support from binhost
emerge -v --oneshot --usepkg --getbinpkg sys-devel/gcc
gcc-config latest
eval "$(gcc-config -E)"
hash -r
cxx_probe=g++
test "$(dirname "$(type -P "${cxx_probe}")")" = "$(gcc-config -B)"
printf '%s\n' 'int main() { return 0; }' | \
	"${cxx_probe}" -x c++ - -o /tmp/cxx-probe
/tmp/cxx-probe

emerge_target_dependencies() {
	emerge -v \
		--onlydeps \
		--usepkg --getbinpkg --binpkg-changed-deps=y \
		--autounmask=y --autounmask-keep-masks=y \
		--autounmask-write=y --autounmask-continue=y \
		--backtrack=50 \
		"${source_atom}"
}
if ! emerge_target_dependencies; then
	emerge_target_dependencies
fi

emerge --fetchonly --nodeps "${source_atom}"
ONLINE

echo "Disconnecting container before offline emerge"
docker network disconnect bridge "${gentoo_container}"
networks=$(docker inspect \
	--format='{{json .NetworkSettings.Networks}}' "${gentoo_container}")
if [[ ${networks} != '{}' ]]; then
	echo "Container still has network attachments: ${networks}" >&2
	exit 1
fi
echo "Network disabled; emerging Flutter Engine offline"

docker exec -i "${gentoo_container}" bash -euxo pipefail -s -- \
	"${source_atom}" <<'OFFLINE'
source_atom=$1
source_pf=${source_atom#=dev-libs/}
source_pf=${source_pf%-r0}

if ! emerge -v --oneshot \
	--usepkg --usepkg-exclude dev-libs/flutter-engine \
	"${source_atom}"; then
	build_log=$(find "/var/tmp/portage/dev-libs/${source_pf}" \
		-path '*/temp/build.log' -print -quit 2>/dev/null || true)
	if [[ -n ${build_log} ]]; then
		echo '===== Flutter Engine Portage build.log ====='
		tail -n 2000 "${build_log}"
		echo '===== end Flutter Engine Portage build.log ====='
	fi
	exit 1
fi

engine_root="/usr/lib/flutter-engine/3.47.2"
linux_x64="${engine_root}/linux-x64"
linux_profile="${engine_root}/linux-x64-profile"
linux_release="${engine_root}/linux-x64-release"
common_sdk="${engine_root}/common/flutter_patched_sdk"
common_sdk_prod="${engine_root}/common/flutter_patched_sdk_product"
sky_engine="${engine_root}/pkg/sky_engine"
flutter_gpu="${engine_root}/pkg/flutter_gpu"

assert_elf_loadable() {
	local artifact=$1
	local dependencies
	local elf_header
	elf_header=$(readelf -h "${artifact}")
	grep -q 'Class:.*ELF64' <<< "${elf_header}"
	dependencies=$(ldd "${artifact}" 2>&1)
	if grep -q 'not found' <<< "${dependencies}"; then
		printf '%s\n' "${dependencies}" >&2
		echo "Unresolved dependency in ${artifact}" >&2
		return 1
	fi
}

assert_success_signature() {
	local signature=$1
	shift
	local output
	output=$("$@" 2>&1)
	grep -Fq "${signature}" <<< "${output}"
}

assert_distinct() {
	local first=$1
	local second=$2
	if cmp -s "${first}" "${second}"; then
		echo "Mode-specific artifacts are unexpectedly identical" >&2
		printf '%s\n' "${first}" "${second}" >&2
		return 1
	fi
}

test -x "${linux_x64}/gen_snapshot"
test -x "${linux_x64}/flutter_tester"
test -x "${linux_x64}/impellerc"
test -x "${linux_x64}/font-subset"
test -f "${linux_x64}/libflutter_linux_gtk.so"
test -f "${linux_x64}/libtessellator.so"
test -f "${linux_x64}/icudtl.dat"
test -f "${linux_x64}/const_finder.dart.snapshot"
test -f "${linux_x64}/isolate_snapshot.bin"
test -f "${linux_x64}/vm_isolate_snapshot.bin"
test -f "${linux_x64}/flutter_linux/flutter_linux.h"
test -f "${linux_x64}/shader_lib/flutter/runtime_effect.glsl"
test -f "${linux_x64}/shader_lib/impeller/types.glsl"

test -x "${linux_profile}/gen_snapshot"
test -f "${linux_profile}/libflutter_linux_gtk.so"
test -f "${linux_profile}/flutter_linux/flutter_linux.h"
test -L "${linux_profile}/flutter_linux"
test "$(readlink "${linux_profile}/flutter_linux")" = \
	'../linux-x64/flutter_linux'

test -x "${linux_release}/gen_snapshot"
test -f "${linux_release}/libflutter_linux_gtk.so"
test -f "${linux_release}/flutter_linux/flutter_linux.h"
test -L "${linux_release}/flutter_linux"
test "$(readlink "${linux_release}/flutter_linux")" = \
	'../linux-x64/flutter_linux'

test -f "${common_sdk}/platform_strong.dill"
test -f "${common_sdk}/vm_outline_strong.dill"
test -f "${common_sdk_prod}/platform_strong.dill"
test -f "${common_sdk_prod}/vm_outline_strong.dill"
test -f "${sky_engine}/pubspec.yaml"
test -f "${sky_engine}/lib/ui/ui.dart"
test -f "${flutter_gpu}/pubspec.yaml"
test -f "${flutter_gpu}/lib/gpu.dart"

test -x /usr/bin/impellerc
test -x /usr/bin/flutter_tester
test -x /usr/bin/gen_snapshot
test -x /usr/bin/font-subset
test -f /usr/lib64/libflutter_linux_gtk.so
test -f /usr/lib64/libtessellator.so
test -f /usr/include/flutter-engine/flutter_linux/flutter_linux.h
test -L /usr/bin/impellerc
test -L /usr/bin/flutter_tester
test -L /usr/bin/gen_snapshot
test -L /usr/bin/font-subset
test -L /usr/lib64/libflutter_linux_gtk.so
test -L /usr/lib64/libtessellator.so
test -L /usr/include/flutter-engine/flutter_linux

for artifact in \
	"${linux_x64}/gen_snapshot" \
	"${linux_x64}/flutter_tester" \
	"${linux_x64}/impellerc" \
	"${linux_x64}/font-subset" \
	"${linux_x64}/libflutter_linux_gtk.so" \
	"${linux_x64}/libtessellator.so" \
	"${linux_profile}/gen_snapshot" \
	"${linux_profile}/libflutter_linux_gtk.so" \
	"${linux_release}/gen_snapshot" \
	"${linux_release}/libflutter_linux_gtk.so"; do
	assert_elf_loadable "${artifact}"
done

assert_success_signature \
	"ImpellerC is an offline shader processor" \
	"${linux_x64}/impellerc" --help
assert_success_signature \
	"flutter_tester" \
	"${linux_x64}/flutter_tester" --help
for snapshotter in \
	"${linux_x64}/gen_snapshot" \
	"${linux_profile}/gen_snapshot" \
	"${linux_release}/gen_snapshot"; do
	assert_success_signature "Dart SDK version" "${snapshotter}" --version
done

if font_output=$("${linux_x64}/font-subset" 2>&1); then
	echo "font-subset unexpectedly accepted missing arguments" >&2
	exit 1
fi
grep -Fq "Usage:" <<< "${font_output}"

for engine_library in \
	"${linux_x64}/libflutter_linux_gtk.so" \
	"${linux_profile}/libflutter_linux_gtk.so" \
	"${linux_release}/libflutter_linux_gtk.so"; do
	dynamic_section=$(readelf -d "${engine_library}")
	grep -q "SONAME" <<< "${dynamic_section}"
done

assert_distinct \
	"${linux_x64}/libflutter_linux_gtk.so" \
	"${linux_profile}/libflutter_linux_gtk.so"
assert_distinct \
	"${linux_profile}/libflutter_linux_gtk.so" \
	"${linux_release}/libflutter_linux_gtk.so"
assert_distinct \
	"${linux_x64}/gen_snapshot" \
	"${linux_profile}/gen_snapshot"
assert_distinct \
	"${linux_profile}/gen_snapshot" \
	"${linux_release}/gen_snapshot"
assert_distinct \
	"${common_sdk}/platform_strong.dill" \
	"${common_sdk_prod}/platform_strong.dill"

for engine_mode in "${linux_x64}" "${linux_profile}" "${linux_release}"; do
	cc -x c -o /tmp/flutter-engine-link-probe - \
		-I"${engine_mode}" \
		$(pkg-config --cflags gtk+-3.0) \
		-L"${engine_mode}" \
		-Wl,-rpath,"${engine_mode}" \
		-lflutter_linux_gtk \
		$(pkg-config --libs gtk+-3.0) <<'PROBE'
#include <flutter_linux/flutter_linux.h>

int main(void) {
	FlValue *value = fl_value_new_null();
	fl_value_unref(value);
	return 0;
}
PROBE
	/tmp/flutter-engine-link-probe
done
OFFLINE

echo "Flutter Engine source build and verification passed successfully"
