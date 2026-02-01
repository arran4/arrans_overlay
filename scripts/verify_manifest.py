#!/usr/bin/env python3
import os
import re
import subprocess
import sys
import hashlib
import urllib.request
import concurrent.futures

def parse_ebuild_variables(filename):
    # Basic parsing for PV, P, PN from filename
    basename = os.path.basename(filename)
    # Regex to capture PN and PV.
    # Example: ollama-bin-0.10.1.ebuild -> PN=ollama-bin, PV=0.10.1
    # Example: g2-bin-0.0.2.ebuild -> PN=g2-bin, PV=0.0.2

    # This regex is a simplification but covers most cases in this overlay
    match = re.match(r'^(?P<pn>.+)-(?P<pv>\d+(\.\d+)*([a-z]|_p\d+|_rc\d+|_beta\d+|_alpha\d+)?(-r\d+)?)\.ebuild$', basename)

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

def parse_manifest(manifest_path):
    entries = {}
    if not os.path.exists(manifest_path):
        return entries

    with open(manifest_path, 'r') as f:
        for line in f:
            parts = line.strip().split()
            # DIST filename size BLAKE2B hash SHA512 hash
            if len(parts) >= 7 and parts[0] == 'DIST':
                filename = parts[1]
                try:
                    size = int(parts[2])
                except ValueError:
                    continue

                hashes = {}
                i = 3
                while i < len(parts) - 1:
                    algo = parts[i]
                    val = parts[i+1]
                    hashes[algo] = val
                    i += 2
                entries[filename] = {'size': size, 'hashes': hashes, 'line': line.strip()}
    return entries

def save_manifest(manifest_path, entries):
    # Sort by filename
    sorted_filenames = sorted(entries.keys())
    with open(manifest_path, 'w') as f:
        for filename in sorted_filenames:
            entry = entries[filename]
            if 'line' in entry:
                f.write(entry['line'] + '\n')
            else:
                # DIST filename size BLAKE2B hash SHA512 hash
                line = f"DIST {filename} {entry['size']}"
                if 'BLAKE2B' in entry['hashes']:
                    line += f" BLAKE2B {entry['hashes']['BLAKE2B']}"
                if 'SHA512' in entry['hashes']:
                    line += f" SHA512 {entry['hashes']['SHA512']}"
                f.write(line + '\n')

def fetch_and_hash(url):
    print(f"    Downloading: {url}")
    try:
        with urllib.request.urlopen(url) as response:
            size = 0
            blake2b = hashlib.blake2b()
            sha512 = hashlib.sha512()
            while True:
                chunk = response.read(8192)
                if not chunk:
                    break
                size += len(chunk)
                blake2b.update(chunk)
                sha512.update(chunk)

            return {
                'size': size,
                'hashes': {
                    'BLAKE2B': blake2b.hexdigest(),
                    'SHA512': sha512.hexdigest()
                }
            }
    except Exception as e:
        print(f"    Error downloading {url}: {e}")
        return None

def process_directory(directory):
    print(f"Processing directory: {directory}")
    manifest_path = os.path.join(directory, 'Manifest')

    manifest_entries = parse_manifest(manifest_path)

    # Find all ebuilds
    ebuilds = [f for f in os.listdir(directory) if f.endswith('.ebuild')]

    if not ebuilds:
        print("No ebuilds found.")
        return

    all_uris = []

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
        all_uris.extend(uris)

    # Process all URIs
    # Remove duplicates? SRC_URI might be repeated across ebuilds?
    # Yes, multiple ebuilds might use same source file.
    # We should deduplicate based on filename, but check if URL matches?
    # Usually same filename means same file.

    # Using a dict to dedupe by filename
    unique_uris = {}
    for url, filename in all_uris:
        if filename not in unique_uris:
            unique_uris[filename] = url
        # If filename exists but url is different?
        # Gentoo forbids collision of filename with different content.
        # So we assume filename uniqueness is sufficient.

    # Prepare tasks
    tasks = []

    # We need to upsert.
    # If using ThreadPoolExecutor

    # To match original logic exactly (which loops ebuilds then URIs):
    # The original logic:
    # For each ebuild:
    #   For each URI:
    #     Upsert(url, filename)

    # Since we collected all URIs, we can process them.

    # BUT wait, the original logic process ebuilds sequentially.
    # And calls upsert.
    # If I batch them, I change the order of printing?
    # That's fine.

    # Also original logic:
    # "Error updating manifest for {url}: {e}"
    # "pass"

    # My logic:
    # Parallel download.

    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        future_to_file = {}
        for filename, url in unique_uris.items():
            # Optimization: If file exists in manifest, verify it?
            # Or just update it?
            # Review said: "Ensure the logic downloads and verifies all URLs"
            # So we download all.
            future = executor.submit(fetch_and_hash, url)
            future_to_file[future] = (filename, url)

        for future in concurrent.futures.as_completed(future_to_file):
            filename, url = future_to_file[future]
            try:
                result = future.result()
                if result:
                    print(f"    Upserting: {url} -> {filename}")
                    # Update manifest entries
                    # Check if changed?

                    # Create entry dict
                    entry = {
                        'size': result['size'],
                        'hashes': result['hashes']
                    }
                    # We lose 'line' here, so it will be regenerated.
                    manifest_entries[filename] = entry
                else:
                    # Download failed.
                    # Original code printed error and passed.
                    # fetch_and_hash prints error.
                    pass
            except Exception as e:
                print(f"    Exception processing {url}: {e}")

    save_manifest(manifest_path, manifest_entries)

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
