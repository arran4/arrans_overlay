#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
set -euo pipefail
files=$(realpath -e "$1")
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/boot/loader/entries" "$tmp/boot/token/1.2.3"
# Mock mount detection only. All generated entries and files are real.
cat > "$tmp/bin/mountpoint" <<'MOCK'
#!/bin/bash
[[ ${MOCK_MOUNTED:-0} == 1 ]]
MOCK
chmod +x "$tmp/bin/mountpoint"
export PATH="$tmp/bin:$PATH"
export KERNEL_INSTALL_LAYOUT=bls KERNEL_INSTALL_BOOT_ROOT="$tmp/boot"
export KERNEL_INSTALL_ENTRY_TOKEN=token
guard() { bash "$files/00-00-maintenance-mount.install" "$@"; }
recovery() { bash "$files/95-maintenance-recovery.install" "$@"; }
fail() { if "$@"; then echo "Unexpected success: $*" >&2; exit 1; fi; }
export MOCK_MOUNTED=0
fail guard add 1.2.3
fail guard remove 1.2.3
fail recovery add 1.2.3
KERNEL_INSTALL_LAYOUT=uki guard add 1.2.3
KERNEL_INSTALL_LAYOUT=uki recovery add 1.2.3
export MOCK_MOUNTED=1
guard add 1.2.3
guard remove 1.2.3
entries="$tmp/boot/loader/entries"
prefix="$entries/maintenance-recovery-token-1.2.3"
cat > "$entries/token-1.2.3.conf" <<'ENTRY'
title Test Linux
version 1.2.3
sort-key test
linux /token/1.2.3/linux
initrd /token/1.2.3/initrd
options rw root=UUID=test resume=UUID=swap systemd.unit=multi-user.target
ENTRY
echo kernel > "$tmp/boot/token/1.2.3/linux"
fail recovery add 1.2.3
[[ ! -e $prefix-ro.conf && ! -e $prefix-bash.conf ]]
echo initrd > "$tmp/boot/token/1.2.3/initrd"
recovery add 1.2.3
grep -Fx 'options ro noresume root=UUID=test systemd.unit=emergency.target systemd.mask=systemd-remount-fs.service' "$prefix-ro.conf"
grep -Fx 'options ro noresume root=UUID=test init=/bin/bash' "$prefix-bash.conf"
grep -Fx 'initrd /token/1.2.3/initrd' "$prefix-bash.conf"
recovery add 1.2.3
cp "$entries/token-1.2.3.conf" "$entries/token-1.2.3+3.conf"
fail recovery add 1.2.3
rm "$entries/token-1.2.3.conf"
recovery add 1.2.3
fail recovery add ../bad
echo unrelated > "$entries/independent.conf"
recovery remove 1.2.3
[[ ! -e $prefix-ro.conf && ! -e $prefix-bash.conf ]]
[[ -f $entries/token-1.2.3+3.conf && -f $entries/independent.conf ]]
echo unmanaged > "$prefix-ro.conf"
fail recovery add 1.2.3
recovery remove 1.2.3
grep -Fx unmanaged "$prefix-ro.conf"
[[ ! -e $prefix-bash.conf ]]
rm "$prefix-ro.conf"
ln -s "$entries/independent.conf" "$prefix-ro.conf"
fail recovery add 1.2.3
recovery remove 1.2.3
[[ -L $prefix-ro.conf ]]
echo "All kernel-install-maintenance tests passed"
