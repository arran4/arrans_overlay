#!/bin/bash
set -e

# Usage: test_ebuilds.sh [-m mode] [ebuilds...]
# Modes:
#   fetch: (default) Only fetch sources
#   merge: Emerge (build and install) the package

MODE="fetch"

while getopts ":m:" opt; do
  case ${opt} in
    m)
      MODE=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

EBUILDS="$@"

if [ -z "$EBUILDS" ]; then
    echo "No ebuilds to test."
    exit 0
fi

echo "Starting test (mode: $MODE) for: $EBUILDS"

# Ensure we have a valid portage setup
if ! command -v ebuild >/dev/null 2>&1; then
    echo "Error: 'ebuild' command not found. This script must be run in a Gentoo environment."
    exit 1
fi

for ebuild_file in $EBUILDS; do
    echo "------------------------------------------------"
    echo "Testing $ebuild_file"

    if [ ! -f "$ebuild_file" ]; then
        echo "File $ebuild_file not found!"
        continue
    fi

    # Clear distfiles to ensure we verify the download URL validity.
    # Only do this if we are in a CI environment or instructed to.
    # We'll assume if this script is run, we want strict checks.
    if [ -d "/var/cache/distfiles" ]; then
        echo "Cleaning /var/cache/distfiles/..."
        rm -rf /var/cache/distfiles/*
    fi

    if [ "$MODE" = "fetch" ]; then
        if ebuild "$ebuild_file" fetch; then
            echo "PASS: $ebuild_file fetch successful."
        else
            echo "FAIL: $ebuild_file fetch failed."
            exit 1
        fi
    elif [ "$MODE" = "merge" ]; then
        # We need to determine the package atom.
        # Simple way: just emerge the file.
        # Note: 'emerge <file>' works if inside the repo or if path is correct.
        # Using --oneshot to avoid adding to world file.
        # We also assume dependencies are handled by portage.
        # The calling environment should configure BINPKG options if desired.

        echo "Attempting to emerge $ebuild_file..."
        if emerge --oneshot --verbose "$ebuild_file"; then
             echo "PASS: $ebuild_file emerge successful."
        else
             echo "FAIL: $ebuild_file emerge failed."
             exit 1
        fi
    else
        echo "Unknown mode: $MODE"
        exit 1
    fi
done

echo "All tests passed."
