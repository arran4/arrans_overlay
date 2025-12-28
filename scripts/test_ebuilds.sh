#!/bin/bash
set -e

# Arguments: list of ebuilds
EBUILDS="$@"

if [ -z "$EBUILDS" ]; then
    echo "No ebuilds to test."
    exit 0
fi

echo "Starting fetch test for: $EBUILDS"

# Ensure we have a valid portage setup
if ! command -v ebuild >/dev/null 2>&1; then
    echo "Error: 'ebuild' command not found. This script must be run in a Gentoo environment."
    exit 1
fi

for ebuild in $EBUILDS; do
    echo "------------------------------------------------"
    echo "Testing $ebuild"

    if [ ! -f "$ebuild" ]; then
        echo "File $ebuild not found!"
        # Depending on how the list is generated, might refer to deleted files.
        # If file is deleted, we skip.
        continue
    fi

    # Clear distfiles to ensure we verify the download URL validity.
    # We remove everything in distfiles to be safe, as finding the specific distfile is hard without parsing.
    # Use with caution in local dev environments!
    if [ -d "/var/cache/distfiles" ]; then
        echo "Cleaning /var/cache/distfiles/..."
        rm -rf /var/cache/distfiles/*
    fi

    # Run fetch
    if ebuild "$ebuild" fetch; then
        echo "PASS: $ebuild fetch successful."
    else
        echo "FAIL: $ebuild fetch failed."
        exit 1
    fi
done

echo "All tests passed."
