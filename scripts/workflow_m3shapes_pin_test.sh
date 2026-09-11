#!/bin/bash
set -e

# Mock input for testing the perl extraction
MOCK_FLAKE_NIX='
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    m3shapes = {
      url = "github:soramanew/m3shapes/32ad9ce328bb77ed349b40a3be10ee9ea610b8ab";
      flake = false;
    };
  };
}
'

echo "Testing Perl regex extraction..."
PIN=$(echo "$MOCK_FLAKE_NIX" | perl -n -e '/github:soramanew\/m3shapes\/([a-f0-9]+)/ && print $1')

if [ "$PIN" = "32ad9ce328bb77ed349b40a3be10ee9ea610b8ab" ]; then
    echo "PASS: Extracted pin successfully"
else
    echo "FAIL: Could not extract pin. Got '$PIN'"
    exit 1
fi

echo "Testing failure on invalid pin format..."
MOCK_FLAKE_NIX_BAD='
{
  inputs = {
    m3shapes = {
      url = "github:soramanew/m3shapes";
    };
  };
}
'

PIN_BAD=$(echo "$MOCK_FLAKE_NIX_BAD" | perl -n -e '/github:soramanew\/m3shapes\/([a-f0-9]+)/ && print $1')

if [ -z "$PIN_BAD" ]; then
    echo "PASS: Properly failed to extract missing pin"
else
    echo "FAIL: Expected empty pin, got '$PIN_BAD'"
    exit 1
fi

echo "All tests passed."
