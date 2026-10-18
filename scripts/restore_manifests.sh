#!/bin/bash
set -euo pipefail

# This script is called by scheduled-daily-tasks.yml and tests to ensure
# exact-byte preservation of Manifests after dedupe runs.

CHANGED=0

# Detect deleted Manifests BEFORE restoring them, to accurately catch missing packages
cd /tmp/manifest-snapshot
while IFS= read -r -d '' manifest; do
  relative=${manifest#./}
  if [ ! -f "$GITHUB_WORKSPACE/$relative" ]; then
    echo "Refusing to continue: dedupe deleted Manifest file: $relative" >&2
    CHANGED=1
  fi
  # Check if all ebuilds in this package dir were deleted
  pkg_dir=$(dirname "$relative")
  if [ -d "$GITHUB_WORKSPACE/$pkg_dir" ] && ! find "$GITHUB_WORKSPACE/$pkg_dir" -maxdepth 1 -name "*.ebuild" | grep -q .; then
    echo "Refusing to continue: dedupe deleted all ebuilds in package: $pkg_dir" >&2
    CHANGED=1
  elif [ ! -d "$GITHUB_WORKSPACE/$pkg_dir" ]; then
    echo "Refusing to continue: dedupe deleted package dir: $pkg_dir" >&2
    CHANGED=1
  fi
done < <(find . -type f -name Manifest -print0)
cd "$GITHUB_WORKSPACE"

# Restore Manifests
while IFS= read -r -d '' manifest; do
  relative=${manifest#/tmp/manifest-snapshot/}
  mkdir -p "$(dirname "$relative")"
  cp -p -- "$manifest" "$relative"
done < <(find /tmp/manifest-snapshot -type f -name Manifest -print0)

# Verify exact-byte preservation without relying on git
while IFS= read -r -d '' manifest; do
  relative=${manifest#./}
  if [ ! -f "/tmp/manifest-snapshot/$relative" ]; then
    echo "Refusing to continue: dedupe added new Manifest file: $relative" >&2
    CHANGED=1
  elif ! cmp -s "$manifest" "/tmp/manifest-snapshot/$relative"; then
    echo "Refusing to continue: dedupe left Manifest changes after restoration: $relative" >&2
    diff -u "/tmp/manifest-snapshot/$relative" "$manifest" >&2 || true
    CHANGED=1
  fi
done < <(find . -type f -name Manifest -print0)

if [ "$CHANGED" -ne 0 ]; then
  exit 1
fi
