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
  --keep-containers  Leave the test containers behind for inspection
  -h, --help         Show this help

Environment overrides:
  FLUTTER_ENGINE_SOURCE_ATOM, DART_VIRTUAL_ATOM
HELP
}

repo_root=$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
cache_root=${XDG_CACHE_HOME:-${HOME}/.cache}
default_dist="${cache_root}/arrans-overlay/flutter-distfiles"
distfiles=${FLUTTER_ENGINE_DISTDIR:-${default_dist}}
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

mkdir -p "${distfiles}"
distfiles=$(cd "${distfiles}" && pwd -P)

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
	gentoo/stage3:latest \
	sleep infinity >/dev/null

echo "Preparing toolchain, dependencies, and distfiles online"
docker exec -i "${gentoo_container}" bash -euxo pipefail -s -- \
	"${source_atom}" "${virtual_atom}" <<'ONLINE'
source_atom=$1
virtual_atom=$2

chmod 777 /var/cache/distfiles
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
cxx_probe="$(portageq envvar CHOST)-g++"
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

test -x "${linux_x64}/gen_snapshot"
test -x "${linux_x64}/flutter_tester"
test -x "${linux_x64}/impellerc"
test -f "${linux_x64}/libflutter_linux_gtk.so"
test -f "${linux_x64}/libtessellator.so"
test -f "${linux_x64}/icudtl.dat"
test -f "${linux_x64}/flutter_linux/flutter_linux.h"
test -f "${engine_root}/common/flutter_patched_sdk/platform_strong.dill"
test -f "${engine_root}/common/flutter_patched_sdk/vm_outline_strong.dill"
test -d "${engine_root}/pkg/sky_engine"

test -x /usr/bin/impellerc
test -f /usr/lib64/libflutter_linux_gtk.so
test -f /usr/lib64/libtessellator.so
test -f /usr/include/flutter-engine/flutter_linux/flutter_linux.h

"${linux_x64}/impellerc" --help >/dev/null 2>&1 || true
"${linux_x64}/flutter_tester" --help >/dev/null 2>&1 || true
OFFLINE

echo "Flutter Engine source build and verification passed successfully"
