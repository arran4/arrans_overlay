#!/bin/bash
set -e

ebuild_dir="$1"
env_epn="$2"
version="$3"
new_content="$4"

# Find latest revision
latest_ebuild=""
latest_rev=-1

# First check for the base version
if [ -e "${ebuild_dir}/${env_epn}-${version}.ebuild" ]; then
    latest_rev=0
    latest_ebuild="${ebuild_dir}/${env_epn}-${version}.ebuild"
fi

# Then check for explicit revisions
for f in "${ebuild_dir}/${env_epn}-${version}-r"*.ebuild; do
  [ -e "$f" ] || continue
  rev="${f##*-r}"
  rev="${rev%.ebuild}"
  if [[ "$rev" =~ ^[0-9]+$ ]] && (( rev > latest_rev )); then
    latest_rev=$rev
    latest_ebuild="$f"
  fi
done

needs_write=false
if [[ "$latest_rev" == -1 ]]; then
  needs_write=true
  ebuild_file="${ebuild_dir}/${env_epn}-${version}.ebuild"
else
  if ! diff -q -I '^\s*#' "$latest_ebuild" <(printf "%s\n" "$new_content") >/dev/null; then
    needs_write=true
    ebuild_file="${ebuild_dir}/${env_epn}-${version}-r$((latest_rev + 1)).ebuild"
  fi
fi

if $needs_write; then
  printf "%s\n" "$new_content" > "$ebuild_file"
  echo "wrote=$ebuild_file"
else
  echo "wrote="
fi
