#!/bin/bash

set -e

# Test the logic from the updater

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' 0

env_ebuild_name="which_browser"
ebuild_dir="$test_dir"

check_exists() {
  local version="$1"
  local ebuild_exists=0
  for f in "${ebuild_dir}/${env_ebuild_name}-${version}".ebuild "${ebuild_dir}/${env_ebuild_name}-${version}"-r*.ebuild; do
    if [ -f "$f" ]; then
      ebuild_exists=1
      break
    fi
  done
  echo $ebuild_exists
}

# 1. Exact unrevisioned ebuild exists
touch "${ebuild_dir}/${env_ebuild_name}-0.2.6.44.ebuild"
res=$(check_exists "0.2.6.44")
if [ "$res" -ne 1 ]; then echo "Failed test 1"; kill -INT $$; fi
rm "${ebuild_dir}/${env_ebuild_name}-0.2.6.44.ebuild"

# 2. -r1 or another numeric revision exists
touch "${ebuild_dir}/${env_ebuild_name}-0.2.6.44-r1.ebuild"
res=$(check_exists "0.2.6.44")
if [ "$res" -ne 1 ]; then echo "Failed test 2"; kill -INT $$; fi
rm "${ebuild_dir}/${env_ebuild_name}-0.2.6.44-r1.ebuild"

# 3. Neither exists
res=$(check_exists "0.2.6.44")
if [ "$res" -ne 0 ]; then echo "Failed test 3"; kill -INT $$; fi

# 4. Prefix collision
touch "${ebuild_dir}/${env_ebuild_name}-1.2.30-r1.ebuild"
res=$(check_exists "1.2.3")
if [ "$res" -ne 0 ]; then echo "Failed test 4"; kill -INT $$; fi
rm "${ebuild_dir}/${env_ebuild_name}-1.2.30-r1.ebuild"

echo "All tests passed!"
