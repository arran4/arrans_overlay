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

# Clear distfiles to ensure we verify the download URL validity.
# Only do this if we are in a CI environment or instructed to.
# We'll assume if this script is run, we want strict checks.
if [ -d "/var/cache/distfiles" ]; then
    echo "Cleaning /var/cache/distfiles/..."
    rm -rf /var/cache/distfiles/*
fi

# Collect valid ebuilds
valid_ebuilds=()
for ebuild_file in $EBUILDS; do
    if [ ! -f "$ebuild_file" ]; then
        echo "File $ebuild_file not found!"
        continue
    fi
    valid_ebuilds+=("$ebuild_file")
done

if [ ${#valid_ebuilds[@]} -eq 0 ]; then
    echo "No valid ebuild files found."
    exit 0
fi

if [ "$MODE" = "fetch" ]; then
    # Parallel fetch logic
    CORES=$(nproc 2>/dev/null || echo 4)
    echo "Fetching in parallel with $CORES jobs..."

    fetch_script='
        ebuild_file="$1"
        echo "------------------------------------------------"
        echo "Testing $ebuild_file"
        if ebuild "$ebuild_file" fetch; then
            echo "PASS: $ebuild_file fetch successful."
        else
            echo "FAIL: $ebuild_file fetch failed."
            exit 1
        fi
    '
    # Use printf to handle spaces in filenames correctly with null delimiter
    # We pass the fetch_script as the command to run. xargs passes the filename as the first argument ($1).
    printf "%s\0" "${valid_ebuilds[@]}" | xargs -0 -P "$CORES" -n 1 bash -c "$fetch_script" _ || {
         echo "One or more fetches failed."
         exit 1
    }

elif [ "$MODE" = "merge" ]; then
    for ebuild_file in "${valid_ebuilds[@]}"; do
        echo "------------------------------------------------"
        echo "Testing $ebuild_file"

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
    done
else
    echo "Unknown mode: $MODE"
    exit 1
fi

echo "All tests passed."
