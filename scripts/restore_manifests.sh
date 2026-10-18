#!/bin/bash
set -euo pipefail

# This script is called by scheduled-daily-tasks.yml and tests to ensure
# exact-byte preservation of Manifests after dedupe runs.

SNAPSHOT_DIR="${1:-/tmp/manifest-snapshot}"
DEDUPE_FAILED="${2:-false}"
CHANGED=0

# Ensure we are inside a valid, usable git repository before proceeding to restore
# A bare repo can return exit 0 but print "false" for --is-inside-work-tree
if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null || echo "false")" != "true" ]; then
  echo "Refusing to continue: Not a valid git repository worktree or broken git metadata" >&2
  CHANGED=1
elif ! git status --porcelain >/dev/null 2>&1; then
  echo "Refusing to continue: git status is unusable" >&2
  CHANGED=1
elif [ "$(realpath "$(git rev-parse --show-toplevel 2>/dev/null || echo "")")" != "$(realpath "$GITHUB_WORKSPACE")" ]; then
  echo "Refusing to continue: git toplevel does not match GITHUB_WORKSPACE" >&2
  CHANGED=1
fi

# Process substitutions do not propagate find's exit status to their while loops.
# Materialize inventories first so any incomplete scan fails closed.
SNAPSHOT_MANIFESTS=$(mktemp)
CURRENT_MANIFESTS=$(mktemp)
trap 'rm -f -- "$SNAPSHOT_MANIFESTS" "$CURRENT_MANIFESTS"' EXIT

if ! (cd "$SNAPSHOT_DIR" && find . -type f -name Manifest -print0 > "$SNAPSHOT_MANIFESTS"); then
  echo "Refusing to continue: failed to enumerate snapshot Manifests" >&2
  exit 1
fi

# Detect deleted Manifests BEFORE restoring them, to accurately catch missing packages
while IFS= read -r -d '' manifest; do
  relative=${manifest#./}
  if [ ! -f "$GITHUB_WORKSPACE/$relative" ]; then
    echo "Refusing to continue: dedupe deleted Manifest file: $relative" >&2
    CHANGED=1
  fi
  # Check if all ebuilds in this package dir were deleted
  pkg_dir=$(dirname "$relative")
  if [ ! -d "$GITHUB_WORKSPACE/$pkg_dir" ]; then
    echo "Refusing to continue: dedupe deleted package dir: $pkg_dir" >&2
    CHANGED=1
  else
    # -quit avoids a grep -q / pipefail SIGPIPE race on large packages.
    if ! found_ebuild=$(find "$GITHUB_WORKSPACE/$pkg_dir" -maxdepth 1 -type f -name '*.ebuild' -print -quit); then
      echo "Refusing to continue: failed to enumerate ebuilds in package: $pkg_dir" >&2
      CHANGED=1
    elif [ -z "$found_ebuild" ]; then
      echo "Refusing to continue: dedupe deleted all ebuilds in package: $pkg_dir" >&2
      CHANGED=1
    fi
  fi
done < "$SNAPSHOT_MANIFESTS"
cd "$GITHUB_WORKSPACE"

# Restore Manifests
while IFS= read -r -d '' manifest; do
  relative=${manifest#./}
  mkdir -p "$(dirname "$relative")"
  cp -p -- "$SNAPSHOT_DIR/$relative" "$relative"
done < "$SNAPSHOT_MANIFESTS"

# Verify exact-byte preservation without relying on git. A failed scan must
# never be mistaken for a clean worktree.
if ! find . -type f -name Manifest -print0 > "$CURRENT_MANIFESTS"; then
  echo "Refusing to continue: failed to enumerate working-tree Manifests" >&2
  exit 1
fi
while IFS= read -r -d '' manifest; do
  relative=${manifest#./}
  if [ ! -f "$SNAPSHOT_DIR/$relative" ]; then
    echo "Refusing to continue: dedupe added new Manifest file: $relative" >&2
    CHANGED=1
  elif ! cmp -s "$manifest" "$SNAPSHOT_DIR/$relative"; then
    echo "Refusing to continue: dedupe left Manifest changes after restoration: $relative" >&2
    diff -u "$SNAPSHOT_DIR/$relative" "$manifest" >&2 || true
    CHANGED=1
  fi
done < "$CURRENT_MANIFESTS"

if [ "$CHANGED" -ne 0 ]; then
  exit 1
fi

if [ "$DEDUPE_FAILED" == "true" ]; then
  echo "Refusing to continue: dedupe command failed." >&2
  exit 1
fi
