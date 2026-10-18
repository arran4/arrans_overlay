#!/bin/bash
set -euo pipefail

echo "Running isolated determinist regression tests for Manifest restoration mechanism"

# Setup testing utility functions
run_test_case() {
  local test_name="$1"
  local mock_setup_func="$2"
  local expected_exit_code="$3"
  local expected_error_grep="${4:-}"
  local pass_dedupe_failed="${5:-false}"

  echo "--- Running Test: $test_name ---"

  local TEST_DIR
  TEST_DIR=$(mktemp -d)
  local REPO_DIR="$TEST_DIR/repo"
  local SNAPSHOT_DIR="$TEST_DIR/manifest-snapshot"

  mkdir -p "$REPO_DIR" "$SNAPSHOT_DIR"

  export GITHUB_WORKSPACE="$REPO_DIR"

  # Base git setup
  (cd "$REPO_DIR" && git init > /dev/null)

  # Call mock setup function
  "$mock_setup_func" "$REPO_DIR" "$SNAPSHOT_DIR"

  local SCRIPT_PATH="$(pwd)/scripts/restore_manifests.sh"
  local ERR_FILE="$TEST_DIR/err.log"

  set +e
  (
    cd "$REPO_DIR"
    bash "$SCRIPT_PATH" "$SNAPSHOT_DIR" "$pass_dedupe_failed"
  ) 2> "$ERR_FILE"
  local EXIT_CODE=$?
  set -e

  if [ "$EXIT_CODE" -ne "$expected_exit_code" ]; then
    echo "FAIL: $test_name expected exit code $expected_exit_code, got $EXIT_CODE"
    cat "$ERR_FILE"
    rm -rf "$TEST_DIR"
    false
  fi

  if [ -n "$expected_error_grep" ]; then
    if ! grep -q "$expected_error_grep" "$ERR_FILE"; then
      echo "FAIL: $test_name did not output expected error: $expected_error_grep"
      cat "$ERR_FILE"
      rm -rf "$TEST_DIR"
      false
    fi
  fi

  echo "PASS: $test_name"
  rm -rf "$TEST_DIR"
}

# --- Test Cases Setup ---

setup_no_change() {
  local repo="$1"
  local snap="$2"
  mkdir -p "$repo/app-misc/pkg" "$snap/app-misc/pkg"
  echo "ebuild" > "$repo/app-misc/pkg/pkg-1.ebuild"
  echo "same" > "$repo/app-misc/pkg/Manifest"
  echo "same" > "$snap/app-misc/pkg/Manifest"
}

setup_modified_bytes_restored() {
  local repo="$1"
  local snap="$2"
  mkdir -p "$repo/app-misc/pkg" "$snap/app-misc/pkg"
  echo "ebuild" > "$repo/app-misc/pkg/pkg-1.ebuild"
  # Dedupe modified it
  echo "modified" > "$repo/app-misc/pkg/Manifest"
  # Snapshot has original
  echo "original" > "$snap/app-misc/pkg/Manifest"
}

setup_added_manifest() {
  local repo="$1"
  local snap="$2"
  mkdir -p "$repo/app-misc/pkg"
  echo "ebuild" > "$repo/app-misc/pkg/pkg-1.ebuild"
  # Dedupe added it
  echo "added" > "$repo/app-misc/pkg/Manifest"
  # Snapshot doesn't have it
}

setup_missing_manifest() {
  local repo="$1"
  local snap="$2"
  mkdir -p "$repo/app-misc/pkg" "$snap/app-misc/pkg"
  echo "ebuild" > "$repo/app-misc/pkg/pkg-1.ebuild"
  # Dedupe deleted it
  # Snapshot has it
  echo "original" > "$snap/app-misc/pkg/Manifest"
}

setup_entire_package_removed() {
  local repo="$1"
  local snap="$2"
  # Dedupe removed the whole thing, repo doesn't have the directory
  # Snapshot has it
  mkdir -p "$snap/app-misc/pkg"
  echo "original" > "$snap/app-misc/pkg/Manifest"
}

setup_last_ebuild_removed() {
  local repo="$1"
  local snap="$2"
  mkdir -p "$repo/app-misc/pkg" "$snap/app-misc/pkg"
  # Dedupe removed the ebuild, leaving an orphan manifest
  echo "same" > "$repo/app-misc/pkg/Manifest"
  echo "same" > "$snap/app-misc/pkg/Manifest"
}

setup_git_missing() {
  local repo="$1"
  local snap="$2"
  # Clean up .git inside the repo
  rm -rf "$repo/.git"
  mkdir -p "$repo/app-misc/pkg" "$snap/app-misc/pkg"
  echo "ebuild" > "$repo/app-misc/pkg/pkg-1.ebuild"
  echo "same" > "$repo/app-misc/pkg/Manifest"
  echo "same" > "$snap/app-misc/pkg/Manifest"
}

# --- Execute Tests ---

run_test_case "unchanged success" setup_no_change 0 ""
run_test_case "changed bytes restored exactly" setup_modified_bytes_restored 0 ""
run_test_case "added Manifest rejected" setup_added_manifest 1 "dedupe added new Manifest file: app-misc/pkg/Manifest"
run_test_case "missing Manifest rejected" setup_missing_manifest 1 "dedupe deleted Manifest file: app-misc/pkg/Manifest"
run_test_case "entire package removed rejected" setup_entire_package_removed 1 "dedupe deleted package dir: app-misc/pkg"
run_test_case "last ebuild removed rejected" setup_last_ebuild_removed 1 "dedupe deleted all ebuilds in package: app-misc/pkg"
run_test_case "nonzero dedupe exact-byte restore failure" setup_no_change 1 "dedupe command failed." true
run_test_case "missing .git rejected" setup_git_missing 1 "Not a git repository or broken git metadata"

echo "All isolated tests PASSED."
