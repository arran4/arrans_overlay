#!/bin/bash
set -Eeuo pipefail

# Build and smoke-test Dart from source in an offline Gentoo container.
#
# Usage: scripts/test_dart_source.sh [--distfiles DIR] [--keep-containers]
#
# The host needs Docker and network access during preparation. The script
# disconnects the test container before emerging dev-lang/dart itself.

usage() {
	cat <<'EOF'
Usage: scripts/test_dart_source.sh [options]

Options:
  --distfiles DIR    Persistent host directory for downloaded distfiles
  --keep-containers  Leave the two test containers behind for inspection
  -h, --help         Show this help

Environment overrides:
  DART_SOURCE_ATOM, DART_BINARY_ATOM, DART_BOOTSTRAP_ATOM, DART_VIRTUAL_ATOM
EOF
}

repo_root=$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
cache_root=${XDG_CACHE_HOME:-${HOME}/.cache}
distfiles=${DART_SOURCE_DISTDIR:-${cache_root}/arrans-overlay/dart-distfiles}
keep_containers=false

while [[ $# -gt 0 ]]; do
	case $1 in
		--distfiles)
			[[ $# -ge 2 ]] || { echo "--distfiles requires a directory" >&2; exit 2; }
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
	echo "Docker is required to run the Dart source integration test" >&2
	exit 1
}

mkdir -p "${distfiles}"
distfiles=$(cd "${distfiles}" && pwd -P)

source_atom=${DART_SOURCE_ATOM:-=dev-lang/dart-3.13.3-r1}
binary_atom=${DART_BINARY_ATOM:-=dev-lang/dart-bin-3.13.3-r2}
bootstrap_atom=${DART_BOOTSTRAP_ATOM:-=dev-lang/dart-bootstrap-bin-3.13.0_beta103_p1-r0}
virtual_atom=${DART_VIRTUAL_ATOM:-=virtual/dart-3.13.3-r1}
container_suffix="${UID:-0}-$$"
portage_container="dart-source-portage-${container_suffix}"
gentoo_container="dart-source-gentoo-${container_suffix}"

cleanup() {
	local status=$?
	trap - EXIT
	if ${keep_containers}; then
		echo "Keeping containers ${gentoo_container} and ${portage_container}"
	else
		docker rm --force "${gentoo_container}" >/dev/null 2>&1 || true
		docker rm --force "${portage_container}" >/dev/null 2>&1 || true
	fi
	exit "${status}"
}
trap cleanup EXIT

echo "Pulling current Gentoo stage3 and Portage images"
docker pull gentoo/stage3:latest
docker pull gentoo/portage:latest

docker create --name "${portage_container}" gentoo/portage:latest >/dev/null
docker run --detach \
	--name "${gentoo_container}" \
	--volumes-from "${portage_container}" \
	--volume "${repo_root}:/var/db/repos/arrans-overlay:ro" \
	--volume "${distfiles}:/var/cache/distfiles:rw" \
	gentoo/stage3:latest \
	sleep infinity >/dev/null

echo "Preparing toolchain, dependencies, virtual resolution, and distfiles online"
docker exec -i "${gentoo_container}" bash -euxo pipefail -s -- \
	"${source_atom}" "${binary_atom}" "${bootstrap_atom}" "${virtual_atom}" <<'ONLINE'
source_atom=$1
binary_atom=$2
bootstrap_atom=$3
virtual_atom=$4

chmod 777 /var/cache/distfiles
mkdir -p /etc/portage/repos.conf
printf '%s\n' \
	'[gentoo]' \
	'location = /var/db/repos/gentoo' \
	'auto-sync = no' \
	> /etc/portage/repos.conf/gentoo.conf
printf '%s\n' \
	'[arrans-overlay]' \
	'location = /var/db/repos/arrans-overlay' \
	'masters = gentoo' \
	'auto-sync = no' \
	> /etc/portage/repos.conf/arrans-overlay.conf

printf '%s\n' \
	'ACCEPT_LICENSE="*"' \
	'FEATURES="${FEATURES} buildpkg"' \
	'CONFIG_PROTECT_MASK="${CONFIG_PROTECT_MASK} /etc/portage/package.accept_keywords /etc/portage/package.use /etc/portage/package.unmask"' \
	>> /etc/portage/make.conf

mkdir -p /etc/portage/package.accept_keywords
printf '%s ~amd64\n' \
	"${source_atom}" \
	"${binary_atom}" \
	"${bootstrap_atom}" \
	"${virtual_atom}" \
	> /etc/portage/package.accept_keywords/dart-source-test

# Prove that virtual/dart can independently resolve to either normal provider.
# The bootstrap must never satisfy the virtual or appear in the binary plan.
mkdir -p /etc/portage/package.mask
printf '%s\n' 'dev-lang/dart-bin' > /etc/portage/package.mask/dart-provider-test
source_plan=$(emerge --pretend --verbose "${virtual_atom}")
printf '%s\n' "${source_plan}"
grep -Fq "${source_atom#=}" <<<"${source_plan}"

printf '%s\n' 'dev-lang/dart' > /etc/portage/package.mask/dart-provider-test
binary_plan=$(emerge --pretend --verbose "${virtual_atom}")
printf '%s\n' "${binary_plan}"
grep -Fq "${binary_atom#=}" <<<"${binary_plan}"
if grep -Fq 'dev-lang/dart-bootstrap-bin-' <<<"${binary_plan}"; then
	echo 'The private bootstrap unexpectedly satisfies virtual/dart' >&2
	exit 1
fi

printf '%s\n' 'dev-lang/dart' 'dev-lang/dart-bin' \
	> /etc/portage/package.mask/dart-provider-test
if unexpected_plan=$(emerge --pretend --verbose "${virtual_atom}" 2>&1); then
	printf '%s\n' "${unexpected_plan}"
	echo 'virtual/dart resolved without either normal Dart provider' >&2
	exit 1
fi
rm /etc/portage/package.mask/dart-provider-test

# The slim Docker stage3 records GCC with USE=cxx but omits cc1plus. Restore
# the complete compiler from Gentoo's binhost and prove it works before the
# container loses network access.
emerge -v --oneshot --usepkg --getbinpkg sys-devel/gcc
cxx_probe="$(portageq envvar CHOST)-g++"
printf '%s\n' 'int main() { return 0; }' | \
	"${cxx_probe}" -x c++ - -o /tmp/dart-cxx-probe
/tmp/dart-cxx-probe

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

source_pf=${source_atom#=dev-lang/}
source_pf=${source_pf%-r0}
if [[ -d /var/db/pkg/dev-lang/${source_pf} ]]; then
	echo 'Dart target was installed before the offline build' >&2
	exit 1
fi
ONLINE

echo "Disconnecting the Gentoo container before the Dart source emerge"
docker network disconnect bridge "${gentoo_container}"
networks=$(docker inspect \
	--format='{{json .NetworkSettings.Networks}}' "${gentoo_container}")
if [[ ${networks} != '{}' ]]; then
	echo "Container still has network attachments: ${networks}" >&2
	exit 1
fi
echo "Network disabled; beginning the source-only Dart emerge"

docker exec -i "${gentoo_container}" bash -euxo pipefail -s -- \
	"${source_atom}" "${bootstrap_atom}" <<'OFFLINE'
source_atom=$1
bootstrap_atom=$2
source_pf=${source_atom#=dev-lang/}
bootstrap_pf=${bootstrap_atom#=dev-lang/}
# Portage omits the explicit revision-zero suffix from VDB directory names.
source_pf=${source_pf%-r0}
bootstrap_pf=${bootstrap_pf%-r0}
bootstrap_root=/opt/dart-bootstrap-3.13.0-103.1.beta

if ! emerge -v --oneshot \
	--usepkg --usepkg-exclude dev-lang/dart \
	"${source_atom}"; then
	build_log=$(find "/var/tmp/portage/dev-lang/${source_pf}" \
		-path '*/temp/build.log' -print -quit 2>/dev/null || true)
	if [[ -n ${build_log} ]]; then
		echo '===== Dart Portage build.log ====='
		tail -n 2000 "${build_log}"
		echo '===== end Dart Portage build.log ====='
	fi
	exit 1
fi

test -d "/var/db/pkg/dev-lang/${source_pf}"
test -d "/var/db/pkg/dev-lang/${bootstrap_pf}"
if compgen -G '/var/db/pkg/dev-lang/dart-bin-*' >/dev/null; then
	echo 'dev-lang/dart-bin must not be installed' >&2
	exit 1
fi

# The seed package may remain installed as a declared BDEPEND, but it owns
# only its private versioned tree and exports no normal Dart provider path.
bootstrap_contents="/var/db/pkg/dev-lang/${bootstrap_pf}/CONTENTS"
test -s "${bootstrap_contents}"
if awk -v root="${bootstrap_root}" \
	'$2 != "/opt" && $2 != root && index($2, root "/") != 1 { print; bad=1 }
	 END { exit bad }' "${bootstrap_contents}"; then
	:
else
	echo 'Bootstrap package owns a path outside its private root' >&2
	exit 1
fi
test ! -e /opt/bin/dart-bootstrap

test "$(readlink -f /opt/bin/dart)" = '/opt/dart-sdk/bin/dart'
test ! -e /opt/dart-sdk/bin/resources/devtools
test -x /opt/dart-sdk/bin/dartaotruntime
test -x /opt/dart-sdk/bin/utils/gen_snapshot
for sdk_payload in \
	bin/snapshots/analysis_server_aot.dart.snapshot \
	bin/snapshots/dart2js_aot.dart.snapshot \
	bin/snapshots/dartdevc_aot.dart.snapshot \
	bin/snapshots/frontend_server_aot.dart.snapshot \
	bin/snapshots/gen_kernel_aot.dart.snapshot \
	lib/_internal/vm_platform_strong.dill \
	lib/core/core.dart \
	lib/libraries.json; do
	test -s "/opt/dart-sdk/${sdk_payload}"
done
if find /opt/dart-sdk -type l -lname '*dart-bootstrap*' \
	-print -quit | grep -q .; then
	echo 'Installed SDK contains a bootstrap symlink' >&2
	exit 1
fi
if grep -Fq 'dart-bootstrap' "/var/db/pkg/dev-lang/${source_pf}/CONTENTS"; then
	echo 'Installed SDK package records a bootstrap path' >&2
	exit 1
fi
for binary in bin/dart bin/dartaotruntime bin/utils/gen_snapshot; do
	if cmp -s "/opt/dart-sdk/${binary}" "${bootstrap_root}/${binary}"; then
		echo "Installed ${binary} unexpectedly matches the bootstrap" >&2
		exit 1
	fi
done

version=$(/opt/bin/dart --version 2>&1)
[[ ${version} == 'Dart SDK version: 3.13.3 (stable)'*'on "linux_x64"' ]]

printf '%s\n' \
	'void main() {' \
	'  print("dart-source-build-ok");' \
	'}' \
	> /tmp/dart-source-smoke.dart
test "$(/opt/bin/dart run /tmp/dart-source-smoke.dart)" = \
	'dart-source-build-ok'
/opt/bin/dart compile exe /tmp/dart-source-smoke.dart \
	-o /tmp/dart-source-smoke
test "$(/tmp/dart-source-smoke)" = 'dart-source-build-ok'
OFFLINE

echo "Dart source build and offline SDK smoke tests passed"
