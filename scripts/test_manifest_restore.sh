#!/bin/bash
set -euo pipefail

echo "Running determinist regression tests for Manifest restoration mechanism"

TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR" /tmp/manifest-snapshot' EXIT

REPO_DIR="$TEST_DIR/repo"
SNAPSHOT_DIR="/tmp/manifest-snapshot"
if [ -d "$SNAPSHOT_DIR" ]; then
    rm -rf "$SNAPSHOT_DIR"
fi
mkdir -p "$SNAPSHOT_DIR"
mkdir -p "$REPO_DIR"

# Need absolute path to the script being tested BEFORE changing directory
SCRIPT_PATH="$(pwd)/scripts/restore_manifests.sh"

cd "$REPO_DIR"
git init > /dev/null

# Test 1: Successful no-change
mkdir -p "$REPO_DIR/app-misc/pkg-no-change"
touch "$REPO_DIR/app-misc/pkg-no-change/Manifest"
echo "ebuild" > "$REPO_DIR/app-misc/pkg-no-change/pkg-no-change-1.ebuild"
mkdir -p "$SNAPSHOT_DIR/app-misc/pkg-no-change"
touch "$SNAPSHOT_DIR/app-misc/pkg-no-change/Manifest"

# Test 2: Modified bytes restored exactly
mkdir -p "$REPO_DIR/app-misc/pkg-diff"
echo "modified" > "$REPO_DIR/app-misc/pkg-diff/Manifest"
echo "ebuild" > "$REPO_DIR/app-misc/pkg-diff/pkg-diff-1.ebuild"
mkdir -p "$SNAPSHOT_DIR/app-misc/pkg-diff"
echo "original" > "$SNAPSHOT_DIR/app-misc/pkg-diff/Manifest"

# Test 3: Added Manifest
mkdir -p "$REPO_DIR/app-misc/pkg-added"
touch "$REPO_DIR/app-misc/pkg-added/Manifest"
echo "ebuild" > "$REPO_DIR/app-misc/pkg-added/pkg-added-1.ebuild"

# Test 4: Removed package directory (dedupe deleted all ebuilds)
mkdir -p "$SNAPSHOT_DIR/app-misc/pkg-deleted-dir"
touch "$SNAPSHOT_DIR/app-misc/pkg-deleted-dir/Manifest"

# Test 5: Removed Manifest only
mkdir -p "$REPO_DIR/app-misc/pkg-deleted-manifest"
echo "ebuild" > "$REPO_DIR/app-misc/pkg-deleted-manifest/pkg-1.ebuild"
mkdir -p "$SNAPSHOT_DIR/app-misc/pkg-deleted-manifest"
touch "$SNAPSHOT_DIR/app-misc/pkg-deleted-manifest/Manifest"

# Test 6: Removal of last ebuild (orphan manifest)
mkdir -p "$REPO_DIR/app-misc/pkg-orphan"
touch "$REPO_DIR/app-misc/pkg-orphan/Manifest"
mkdir -p "$SNAPSHOT_DIR/app-misc/pkg-orphan"
touch "$SNAPSHOT_DIR/app-misc/pkg-orphan/Manifest"

export GITHUB_WORKSPACE="$REPO_DIR"

ERR_FILE="$TEST_DIR/err.log"
set +e
bash "$SCRIPT_PATH" 2> "$ERR_FILE"
EXIT_CODE=$?
set -e

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "FAIL: Expected the script to fail and report changes, but it exited 0."
  cat "$ERR_FILE"
  false
fi

echo "Errors caught as expected:"
cat "$ERR_FILE"

if [ "$(cat "$REPO_DIR/app-misc/pkg-diff/Manifest")" != "original" ]; then
    echo "FAIL: Restore failed to revert pkg-diff/Manifest to original"
    false
else
    echo "Restore successfully reverted pkg-diff/Manifest to original"
fi

grep -q "dedupe added new Manifest file: app-misc/pkg-added/Manifest" "$ERR_FILE" || { echo "Failed to detect added Manifest"; false; }
grep -q "dedupe deleted package dir: app-misc/pkg-deleted-dir" "$ERR_FILE" || { echo "Failed to detect deleted package dir"; false; }
grep -q "dedupe deleted Manifest file: app-misc/pkg-deleted-manifest/Manifest" "$ERR_FILE" || { echo "Failed to detect deleted Manifest"; false; }
grep -q "dedupe deleted all ebuilds in package: app-misc/pkg-orphan" "$ERR_FILE" || { echo "Failed to detect orphan Manifest dir"; false; }

if grep -q "app-misc/pkg-no-change" "$ERR_FILE"; then
  echo "Failed: falsely flagged pkg-no-change"
  false
fi

echo "All script edge cases successfully detected."

rm -rf "$REPO_DIR/.git"

echo "PASS"
