#!/usr/bin/env bash
set -euo pipefail

bundle=${1:-/opt/flutter-jules}
binary=${bundle}/flutter_jules
desktop_file=/usr/share/applications/com.arran4.flutter_jules.desktop
icon_file=/usr/share/icons/hicolor/256x256/apps/com.arran4.flutter_jules.png

fail() {
  echo "flutter-jules test: $*" >&2
  exit 1
}

[[ -d "${bundle}" ]] || fail "missing bundle directory: ${bundle}"
[[ -x "${binary}" ]] || fail "missing executable: ${binary}"
for launcher in /usr/bin/flutter_jules /usr/bin/jules_client; do
  [[ -L "${launcher}" ]] || fail "missing launcher symlink: ${launcher}"
  [[ "$(readlink -f "${launcher}")" == "${binary}" ]] ||
    fail "${launcher} does not resolve to packaged binary"
done
[[ -f "${bundle}/lib/libapp.so" ]] || fail "missing Dart AOT library"
[[ -f "${bundle}/lib/libflutter_linux_gtk.so" ]] || fail "missing Flutter engine library"
[[ -f "${bundle}/data/icudtl.dat" ]] || fail "missing ICU data"
[[ -d "${bundle}/data/flutter_assets" ]] || fail "missing Flutter asset bundle"
[[ -f "${desktop_file}" ]] || fail "missing desktop file"
[[ -f "${icon_file}" ]] || fail "missing application icon"
grep -Fqx 'Exec=flutter_jules' "${desktop_file}" || fail "desktop launcher is not the upstream executable"
grep -Fqx 'Icon=com.arran4.flutter_jules' "${desktop_file}" || fail "desktop icon name is incorrect"

check_elf_deps() {
  local file=$1
  local output

  output=$(ldd "${file}" 2>&1) || {
    printf '%s\n' "${output}" >&2
    fail "ldd failed for ${file}"
  }
  printf '%s\n' "${output}"
  if grep -Fq 'not found' <<<"${output}"; then
    fail "unresolved shared library dependency in ${file}"
  fi
}

check_elf_deps "${binary}"
while IFS= read -r -d '' library; do
  check_elf_deps "${library}"
done < <(find "${bundle}/lib" -maxdepth 1 -type f -name '*.so*' -print0)

echo "flutter-jules test: installed source build is structurally complete"
