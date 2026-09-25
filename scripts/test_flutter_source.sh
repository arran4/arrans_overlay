#!/bin/bash
set -Eeuo pipefail

# Build and smoke-test Flutter (dev-lang/flutter) from source in an offline container.
#
# Usage: scripts/test_flutter_source.sh [--distfiles DIR] [--binpkgs DIR]
#
# The host needs Docker and network access during preparation. The script
# disconnects the test container before emerging dev-lang/flutter and running
# tests offline.

usage() {
	cat <<'HELP'
Usage: scripts/test_flutter_source.sh [options]

Options:
  --distfiles DIR    Persistent host directory for downloaded distfiles
  --binpkgs DIR      Persistent host directory for binary packages
  --keep-containers  Leave the test containers behind for inspection
  -h, --help         Show this help

Environment overrides:
  FLUTTER_SOURCE_ATOM, FLUTTER_ENGINE_SOURCE_ATOM, DART_VIRTUAL_ATOM,
  FLUTTER_DISTDIR, FLUTTER_BINPKGS
HELP
}

repo_root=$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
cache_root=${XDG_CACHE_HOME:-${HOME}/.cache}
default_dist="${cache_root}/arrans-overlay/flutter-distfiles"
distfiles=${FLUTTER_DISTDIR:-${default_dist}}
default_binpkgs="${cache_root}/arrans-overlay/binpkgs"
binpkgs=${FLUTTER_BINPKGS:-${PKGDIR:-${default_binpkgs}}}
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
	echo "Docker is required for Flutter source integration test" >&2
	exit 1
}

mkdir -p "${distfiles}" "${binpkgs}"
distfiles=$(cd "${distfiles}" && pwd -P)
binpkgs=$(cd "${binpkgs}" && pwd -P)

flutter_source_atom=${FLUTTER_SOURCE_ATOM:-=dev-lang/flutter-3.47.2}
flutter_virtual_atom="=virtual/flutter-3.47.2"
flutter_bin_atom="=dev-lang/flutter-bin-3.47.2-r1"
engine_source_atom=${FLUTTER_ENGINE_SOURCE_ATOM:-=dev-libs/flutter-engine-3.47.2}
dart_virtual_atom=${DART_VIRTUAL_ATOM:-=virtual/dart-3.13.3-r1}

container_suffix="${UID:-0}-$$"
portage_container="flutter-source-portage-${container_suffix}"
gentoo_container="flutter-source-gentoo-${container_suffix}"
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
	"${flutter_source_atom}" \
	"${flutter_virtual_atom}" \
	"${flutter_bin_atom}" \
	"${engine_source_atom}" \
	"${dart_virtual_atom}" <<'ONLINE'
flutter_source_atom=$1
flutter_virtual_atom=$2
flutter_bin_atom=$3
engine_source_atom=$4
dart_virtual_atom=$5

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
	"${flutter_source_atom}" \
	"${flutter_virtual_atom}" \
	"${flutter_bin_atom}" \
	"${engine_source_atom}" \
	"${dart_virtual_atom}" \
	'dev-lang/dart' \
	'games-util/libtess2' \
	> /etc/portage/package.accept_keywords/flutter-source-test

# GCC with C++ support from binhost
emerge -v --oneshot --usepkg --getbinpkg sys-devel/gcc
gcc-config latest
eval "$(gcc-config -E)"
hash -r
cxx_probe=g++
test "$(dirname "$(type -P "${cxx_probe}")")" = "$(gcc-config -B)"

# Install GTK+ and desktop dependencies required for building Flutter apps on Linux
emerge -v --usepkg --getbinpkg \
	x11-libs/gtk+:3 \
	dev-build/cmake \
	dev-build/ninja \
	virtual/pkgconfig

# Ensure Dart and Flutter Engine dependencies are emerged (using binpkg cache if present)
emerge -v --usepkg --getbinpkg --binpkg-changed-deps=y \
	"${dart_virtual_atom}" \
	"${engine_source_atom}"

# Pre-fetch all declared distfiles for source flutter
emerge --fetchonly --nodeps "${flutter_source_atom}"

# Create non-root test user
useradd --create-home --shell /bin/bash fluttertest
install -d -o fluttertest -g fluttertest /home/fluttertest/.cache
ONLINE

echo "Disconnecting container before offline emerge"
docker network disconnect bridge "${gentoo_container}"
networks=$(docker inspect \
	--format='{{json .NetworkSettings.Networks}}' "${gentoo_container}")
if [[ ${networks} != '{}' ]]; then
	echo "Container still has network attachments: ${networks}" >&2
	exit 1
fi
echo "Network disabled; emerging dev-lang/flutter and virtual/flutter offline"

docker exec -i "${gentoo_container}" bash -euxo pipefail -s -- \
	"${flutter_source_atom}" \
	"${flutter_virtual_atom}" \
	"${flutter_bin_atom}" <<'OFFLINE'
flutter_source_atom=$1
flutter_virtual_atom=$2
flutter_bin_atom=$3

# Build and install dev-lang/flutter offline from source
if ! emerge -v --oneshot "${flutter_source_atom}"; then
	build_log=$(find /var/tmp/portage/dev-lang/flutter-3.47.2 -path "*/temp/build.log" -print -quit 2>/dev/null || true)
	if [ -n "${build_log}" ]; then
		echo "===== dev-lang/flutter Portage build.log ====="
		cat "${build_log}"
		echo "===== end dev-lang/flutter Portage build.log ====="
	fi
	exit 1
fi

# Install virtual/flutter
emerge -v --oneshot "${flutter_virtual_atom}"

# Verify blocker prevents flutter-bin from installing alongside source flutter
echo "Verifying dev-lang/flutter-bin blocker enforcement"
if emerge --pretend "${flutter_bin_atom}" 2>&1 | grep -q "blocks"; then
	echo "Blocker correctly detected for ${flutter_bin_atom}"
else
	echo "ERROR: Blocker failed: ${flutter_bin_atom} did not report block against ${flutter_source_atom}" >&2
	emerge --pretend "${flutter_bin_atom}" || true
	exit 1
fi

# Canonical executable checks
test -x /usr/bin/flutter
test -L /opt/bin/flutter
test "$(readlink /opt/bin/flutter)" = "../../usr/bin/flutter"

# Make the package-managed SDK root strictly read-only to verify XDG cache usage
chmod -R a-w /opt/flutter
find /opt/flutter -xdev -printf "%P %y %m\n" | sort > /tmp/flutter-tree.before
find /opt/flutter -xdev -type f -print0 | sort -z | xargs -0 sha256sum > /tmp/flutter-files.before
OFFLINE

echo "Running offline smoke tests as non-root user fluttertest"
docker exec \
	--user fluttertest \
	--env HOME=/home/fluttertest \
	--env XDG_CACHE_HOME=/home/fluttertest/.cache \
	--env CI=true \
	--workdir /home/fluttertest \
	"${gentoo_container}" \
	bash -euxo pipefail <<'SMOKE'
# 1. flutter --version checks
version_out=$(flutter --version)
echo "${version_out}"
echo "${version_out}" | grep -q "Flutter 3.47.2"
echo "${version_out}" | grep -q "Engine • hash a804b261645ef8c13eb3d5c44a5c2fb0340c5539"
echo "${version_out}" | grep -q "Dart 3.13.3"

# 2. flutter doctor checks
flutter doctor --suppress-analytics

# 3. Verify user cache layout and symlink preserving
test -L "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/dart-sdk"
test -L "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/artifacts/engine/linux-x64"
test -L "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/artifacts/engine/linux-x64-profile"
test -L "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/artifacts/engine/linux-x64-release"
test -L "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/artifacts/engine/common/flutter_patched_sdk"
test -L "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/artifacts/engine/common/flutter_patched_sdk_product"
test -L "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/pkg/sky_engine"
test -w "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache"
test ! -w /opt/flutter

# Verify stamps
test "$(cat "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/.gentoo-flutter-seed-version")" = "3.47.2"
test "$(cat "${XDG_CACHE_HOME}/flutter/pub-cache/.gentoo-flutter-pub-seed-version")" = "3.47.2"

# 4. Cache refresh on stale stamp
echo "stale" > "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/.gentoo-flutter-seed-version"
flutter --version
test "$(cat "${XDG_CACHE_HOME}/flutter/3.47.2/bin-cache/.gentoo-flutter-seed-version")" = "3.47.2"

# 5. Offline sample app create and build
flutter create --offline --empty --platforms=linux app
cd app
flutter build linux --debug
test -f build/linux/x64/debug/bundle/app

flutter build linux --release
test -f build/linux/x64/release/bundle/app
test -f build/linux/x64/release/bundle/lib/libapp.so
SMOKE

echo "Verifying package-managed SDK remained untouched"
docker exec "${gentoo_container}" bash -euxo pipefail <<'VERIFY'
find /opt/flutter -xdev -printf "%P %y %m\n" | sort > /tmp/flutter-tree.after
diff -u /tmp/flutter-tree.before /tmp/flutter-tree.after
sha256sum --check /tmp/flutter-files.before
echo "All package-managed Flutter files unmodified!"
VERIFY

echo "Flutter source integration test completed successfully!"
