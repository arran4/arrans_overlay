#!/bin/bash
set -euo pipefail

# Create temporary directory for fixtures
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Create nested .github/workflows directory inside the temporary directory
mkdir -p "$TMP_DIR/.github/workflows"

# Handwritten good
cat << 'FIXTURE' > "$TMP_DIR/.github/workflows/good.yaml"
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
FIXTURE

# Handwritten bad
cat << 'FIXTURE' > "$TMP_DIR/.github/workflows/dev-vcs-kgithub-notify-update.yaml"
concurrency:
  group: ci-${{ github.ref }}
FIXTURE

# Generated bad
cat << 'FIXTURE' > "$TMP_DIR/.github/workflows/bad_generated.yaml"
# Generated using: arrans_overlay_workflow_builder
concurrency:
  group: ci-${{ github.ref }}
FIXTURE

echo "--- Testing good manual (should exit 0)"
# Run on just the good fixture (temporarily move bad ones)
mv "$TMP_DIR/.github/workflows/dev-vcs-kgithub-notify-update.yaml" "$TMP_DIR/dev-vcs-kgithub-notify-update.yaml"
mv "$TMP_DIR/.github/workflows/bad_generated.yaml" "$TMP_DIR/bad_generated.yaml"
set +e
output=$(./scripts/test_workflow_concurrency.sh manual "$TMP_DIR/.github/workflows")
exit_code=$?
set -e
mv "$TMP_DIR/dev-vcs-kgithub-notify-update.yaml" "$TMP_DIR/.github/workflows/dev-vcs-kgithub-notify-update.yaml"
mv "$TMP_DIR/bad_generated.yaml" "$TMP_DIR/.github/workflows/bad_generated.yaml"
if [ $exit_code -ne 0 ]; then
    echo "Output was: $output"
    echo "Failed: Good manual should exit 0 and pass. Actual: $exit_code"
    exit 1
fi
if ! echo "$output" | grep -q "All checked workflows have proper concurrency groups"; then
    echo "Output was: $output"
    echo "Failed: Did not output correct diagnostic for good manual."
    exit 1
fi

echo "--- Testing bad manual (should exit 1)"
set +e
output=$(./scripts/test_workflow_concurrency.sh manual "$TMP_DIR/.github/workflows")
exit_code=$?
set -e
if [ $exit_code -ne 1 ]; then
    echo "Failed: bad manual should exit exactly 1. Actual: $exit_code"
    exit 1
fi
if ! echo "$output" | grep -q "Error (Manual): $TMP_DIR/.github/workflows/dev-vcs-kgithub-notify-update.yaml uses overly broad concurrency group"; then
    echo "Failed: Did not output correct diagnostic for bad manual."
    echo "Output was: $output"
    exit 1
fi

echo "--- Testing generated warning in manual mode (should exit 0)"
# Remove the manual bad file so it should pass now
rm "$TMP_DIR/.github/workflows/dev-vcs-kgithub-notify-update.yaml"
set +e
output=$(./scripts/test_workflow_concurrency.sh manual "$TMP_DIR/.github/workflows")
exit_code=$?
set -e
if [ $exit_code -ne 0 ]; then
    echo "Failed: generated bad file in manual mode should exit 0. Actual: $exit_code"
    exit 1
fi
if ! echo "$output" | grep -q "Inventory: Found 1 generated workflows with overly broad concurrency groups."; then
    echo "Failed: Did not properly inventory the generated workflow."
    echo "Output was: $output"
    exit 1
fi

echo "--- Testing generated bad in strict mode (should exit 1)"
set +e
output=$(./scripts/test_workflow_concurrency.sh strict "$TMP_DIR/.github/workflows")
exit_code=$?
set -e
if [ $exit_code -ne 1 ]; then
    echo "Failed: generated bad file in strict mode should exit exactly 1. Actual: $exit_code"
    exit 1
fi
if ! echo "$output" | grep -q "Error (Generated): $TMP_DIR/.github/workflows/bad_generated.yaml uses overly broad concurrency group"; then
    echo "Failed: Did not correctly diagnostic generated workflow in strict mode."
    echo "Output was: $output"
    exit 1
fi

echo "Fixture tests passed."
