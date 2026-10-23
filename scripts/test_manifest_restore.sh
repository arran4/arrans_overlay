#!/bin/bash
set -euo pipefail

echo "Running isolated determinist regression tests for Manifest restoration mechanism"

RESTORE_SCRIPT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/restore_manifests.sh"

# Setup testing utility functions
run_test_case() {
  local test_name="$1"
  local mock_setup_func="$2"
  local expected_exit_code="$3"
  local expected_error_grep="${4:-}"
  local pass_dedupe_failed="${5:-false}"
  local post_assert_func="${6:-}"
  local fail_find="${7:-false}"

  echo "--- Running Test: $test_name ---"

  local TEST_DIR
  TEST_DIR=$(mktemp -d)
  local REPO_DIR="$TEST_DIR/repo"
  local SNAPSHOT_DIR="$TEST_DIR/manifest-snapshot"

  mkdir -p "$REPO_DIR" "$SNAPSHOT_DIR"

  export GITHUB_WORKSPACE="$REPO_DIR"

  # Base git setup
  (cd "$REPO_DIR" && git init > /dev/null && git config user.name "test" && git config user.email "test@example.com" && git commit --allow-empty -m "init")

  # Call mock setup function
  "$mock_setup_func" "$REPO_DIR" "$SNAPSHOT_DIR"

  local ERR_FILE="$TEST_DIR/err.log"
  local test_path="$PATH"
  if [ "$fail_find" = "true" ]; then
    # Inject an inventory scan error to prove we do not accept partial find output.
    mkdir -p "$TEST_DIR/bin"
    printf '#!/bin/sh\nexit 37\n' > "$TEST_DIR/bin/find"
    chmod +x "$TEST_DIR/bin/find"
    test_path="$TEST_DIR/bin:$PATH"
  fi

  set +e
  (
    cd "$REPO_DIR"
    PATH="$test_path" bash "$RESTORE_SCRIPT" "$SNAPSHOT_DIR" "$pass_dedupe_failed"
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

  if [ -n "$post_assert_func" ]; then
    "$post_assert_func" "$REPO_DIR" "$SNAPSHOT_DIR" "$ERR_FILE" || { echo "FAIL: post-assertion for $test_name failed"; rm -rf "$TEST_DIR"; false; }
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

assert_bytes_restored() {
  local repo="$1"
  local snap="$2"
  local err="$3"
  if ! cmp -s "$repo/app-misc/pkg/Manifest" "$snap/app-misc/pkg/Manifest"; then
     echo "Post-assert FAIL: Bytes were not restored correctly."
     return 1
  fi
  if [ "$(cat "$repo/app-misc/pkg/Manifest")" != "original" ]; then
     echo "Post-assert FAIL: Content not what we expect ('original')."
     return 1
  fi
  return 0
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

setup_git_bare() {
  local repo="$1"
  local snap="$2"
  # Replace the initialized standard repo with a bare repo
  rm -rf "$repo/.git"
  git init --bare "$repo" > /dev/null
  mkdir -p "$repo/app-misc/pkg" "$snap/app-misc/pkg"
  echo "ebuild" > "$repo/app-misc/pkg/pkg-1.ebuild"
  echo "same" > "$repo/app-misc/pkg/Manifest"
  echo "same" > "$snap/app-misc/pkg/Manifest"
}

# --- Execute Tests ---

setup_root_manifest() {
  local repo="$1"
  local snap="$2"
  mkdir -p "$repo/app-misc/pkg" "$snap/app-misc/pkg"
  echo "ebuild" > "$repo/app-misc/pkg/pkg-1.ebuild"
  echo "package" > "$repo/app-misc/pkg/Manifest"
  echo "package" > "$snap/app-misc/pkg/Manifest"
  echo "changed by dedupe" > "$repo/Manifest"
  echo "original root manifest" > "$snap/Manifest"
}

assert_root_manifest_restored() {
  cmp -s "$1/Manifest" "$2/Manifest"
}

run_test_case "root Manifest is not a package and bytes are restored" setup_root_manifest 0 "" false assert_root_manifest_restored
run_test_case "unchanged success" setup_no_change 0 ""
run_test_case "changed bytes restored exactly" setup_modified_bytes_restored 0 "" false assert_bytes_restored
run_test_case "added Manifest rejected" setup_added_manifest 1 "dedupe added new Manifest file: app-misc/pkg/Manifest"
run_test_case "missing Manifest rejected" setup_missing_manifest 1 "dedupe deleted Manifest file: app-misc/pkg/Manifest"
run_test_case "entire package removed rejected" setup_entire_package_removed 1 "dedupe deleted package dir: app-misc/pkg"
run_test_case "last ebuild removed rejected" setup_last_ebuild_removed 1 "dedupe deleted all ebuilds in package: app-misc/pkg"
run_test_case "nonzero dedupe exact-byte restore failure" setup_modified_bytes_restored 1 "dedupe command failed." true assert_bytes_restored
run_test_case "missing .git rejected" setup_git_missing 1 "Not a valid git repository worktree or broken git metadata"
run_test_case "bare .git rejected" setup_git_bare 1 "Not a valid git repository worktree or broken git metadata"
run_test_case "failed inventory scan rejected" setup_no_change 1 "failed to enumerate snapshot Manifests" false "" true

# Simulate the actual snapshot logic from scheduled-daily-tasks.yml
echo "--- Running Test: integration snapshot simulation ---"
TEST_DIR=$(mktemp -d)
REPO_DIR="$TEST_DIR/repo"
SNAPSHOT_DIR="$TEST_DIR/manifest-snapshot"
mkdir -p "$REPO_DIR"
export GITHUB_WORKSPACE="$REPO_DIR"

(cd "$REPO_DIR" && git init > /dev/null && git config user.name "test" && git config user.email "test@example.com" && git commit --allow-empty -m "init")
mkdir -p "$REPO_DIR/app-misc/pkg"
echo "ebuild" > "$REPO_DIR/app-misc/pkg/pkg-1.ebuild"
echo "original" > "$REPO_DIR/app-misc/pkg/Manifest"

(
  cd "$REPO_DIR"
  # Workflow-equivalent inventory and snapshot logic.
  mkdir -p "$SNAPSHOT_DIR"
  manifest_list=$(mktemp)
  trap 'rm -f -- "$manifest_list"' EXIT
  find . -type f -name Manifest -print0 > "$manifest_list"
  while IFS= read -r -d '' manifest; do
    relative=${manifest#./}
    mkdir -p "$SNAPSHOT_DIR/$(dirname "$relative")"
    cp -p -- "$manifest" "$SNAPSHOT_DIR/$relative"
  done < "$manifest_list"
)

# Mutate repo
echo "modified" > "$REPO_DIR/app-misc/pkg/Manifest"

# Run restore script
set +e
(
  cd "$REPO_DIR"
  bash "$RESTORE_SCRIPT" "$SNAPSHOT_DIR" "false"
) 2> "$TEST_DIR/err.log"
EXIT_CODE=$?
set -e

if [ "$EXIT_CODE" -ne 0 ]; then
  echo "FAIL: integration expected 0, got $EXIT_CODE"
  cat "$TEST_DIR/err.log"
  rm -rf "$TEST_DIR"
  false
fi

if ! cmp -s "$REPO_DIR/app-misc/pkg/Manifest" "$SNAPSHOT_DIR/app-misc/pkg/Manifest"; then
  echo "FAIL: integration cmp failed"
  rm -rf "$TEST_DIR"
  false
fi

echo "PASS: integration snapshot simulation"
rm -rf "$TEST_DIR"

echo "All isolated tests PASSED."
