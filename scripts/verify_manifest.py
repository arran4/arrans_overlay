#!/usr/bin/env python3
import os
import re
import subprocess
import sys

# Regex to capture PN and PV from ebuild filename.
# Example: ollama-bin-0.10.1.ebuild -> PN=ollama-bin, PV=0.10.1
# Example: g2-bin-0.0.2.ebuild -> PN=g2-bin, PV=0.0.2
# This regex is a simplification but covers most cases in this overlay
EBUILD_FILENAME_PATTERN = re.compile(r'^(?P<pn>.+)-(?P<pv>\d+(\.\d+)*([a-z]|_p\d+|_rc\d+|_beta\d+|_alpha\d+)?(-r\d+)?)\.ebuild$')

def parse_ebuild_variables(filename):
    # Basic parsing for PV, P, PN from filename
    basename = os.path.basename(filename)

    match = EBUILD_FILENAME_PATTERN.match(basename)

    if not match:
        return None

    pn = match.group('pn')
    pv = match.group('pv')
    p = f"{pn}-{pv}"

    return {
        'P': p,
        'PN': pn,
        'PV': pv,
    }

def resolve_variables(text, variables):
    # Replace ${VAR} and $VAR
    for key, value in variables.items():
        text = text.replace(f"${{{key}}}", value)
        text = text.replace(f"${key}", value)
    return text

def extract_uris(content, variables):
    # Remove comments
    lines = [line.split('#', 1)[0] for line in content.splitlines()]
    clean_content = '\n'.join(lines)

    # Find SRC_URI block
    # It might use " or '
    match = re.search(r'SRC_URI\s*=\s*"([^"]*)"', clean_content, re.DOTALL)
    if not match:
        match = re.search(r"SRC_URI\s*=\s*'([^']*)'", clean_content, re.DOTALL)

    if not match:
        return []

    src_uri_body = match.group(1)

    # Simple tokenizer
    tokens = src_uri_body.split()

    uris = []
    i = 0
    while i < len(tokens):
        token = tokens[i]

        # Check if it looks like a URL
        if '://' in token:
            url = token
            filename = os.path.basename(url)

            # Check for -> rename
            if i + 2 < len(tokens) and tokens[i+1] == '->':
                filename = tokens[i+2]
                i += 3 # skip url, ->, filename
            else:
                i += 1 # skip url

            # Resolve variables in both URL and filename
            url = resolve_variables(url, variables)
            filename = resolve_variables(filename, variables)

            uris.append((url, filename))
        else:
            i += 1

    return uris

def process_directory(directory):
    print(f"Processing directory: {directory}")
    manifest_path = os.path.join(directory, 'Manifest')

    # Find all ebuilds
    ebuilds = [f for f in os.listdir(directory) if f.endswith('.ebuild')]

    if not ebuilds:
        print("No ebuilds found.")
        return

    for ebuild in ebuilds:
        ebuild_path = os.path.join(directory, ebuild)
        print(f"  Parsing {ebuild}...")

        variables = parse_ebuild_variables(ebuild)
        if not variables:
            print(f"  Skipping {ebuild}: Could not parse version/name.")
            continue

        with open(ebuild_path, 'r') as f:
            content = f.read()

        uris = extract_uris(content, variables)

        for url, filename in uris:
            print(f"    Upserting: {url} -> {filename}")
            try:
                subprocess.run(['g2', 'manifest', 'upsert-from-url', url, filename, manifest_path], check=True)
            except subprocess.CalledProcessError as e:
                print(f"    Error updating manifest for {url}: {e}")
                # We might want to exit or continue?
                # If a URL is dead, this might fail.
                # But the request implies fixing the manifest. If URL is dead, we can't fix it easily.
                pass

def main():
    if len(sys.argv) < 2:
        print("Usage: verify_manifest.py <directory1> [directory2 ...]")
        sys.exit(1)

    for directory in sys.argv[1:]:
        if os.path.isdir(directory):
            process_directory(directory)
        else:
            print(f"Directory not found: {directory}")

if __name__ == "__main__":
    main()
