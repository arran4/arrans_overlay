#!/usr/bin/env bash
set -euo pipefail

ebuild="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/sys-fs/efi-automount/efi-automount-1.ebuild"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
mkdir -p "${tmp}/etc"

inherit() { :; }
systemd_dounit() { :; }
elog() { :; }
die() { printf '%s\n' "$*" >&2; return 1; }
export EROOT="${tmp}/"
export FILESDIR="${tmp}/files"
export WORKDIR="${tmp}/work"
# shellcheck source=/dev/null
source "${ebuild}"

if (pkg_pretend) >/dev/null 2>&1; then
	echo 'pkg_pretend accepted missing fstab' >&2
	exit 1
fi

printf 'UUID=other /other ext4 defaults 0 2\n' > "${tmp}/etc/fstab"
if (pkg_pretend) >/dev/null 2>&1; then
	echo 'pkg_pretend accepted unrelated entry' >&2
	exit 1
fi

printf '# UUID=ignored /efi vfat defaults 0 2\n' > "${tmp}/etc/fstab"
if (pkg_preinst) >/dev/null 2>&1; then
	echo 'pkg_preinst accepted only a commented entry' >&2
	exit 1
fi

printf 'UUID=present /efi vfat defaults 0 2\n' > "${tmp}/etc/fstab"
pkg_pretend
pkg_preinst

grep -qxF 'UUID=present /efi vfat defaults 0 2' "${tmp}/etc/fstab"
echo 'efi-automount: fstab preflight OK'
