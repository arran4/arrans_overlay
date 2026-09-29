#!/usr/bin/env python3
import os
import re
import subprocess
import sys
import concurrent.futures
import tempfile
import shutil

EBUILD_FILENAME_PATTERN = re.compile(
    r'^(?P<pn>.+)-'
    r'(?P<pv>\d+(?:\.\d+)*(?:[a-z])?'
    r'(?:(?:_p|_rc|_beta|_alpha|_pre)\d*)*)'
    r'(?:-r(?P<pr>\d+))?\.ebuild$'
)

def parse_ebuild_variables(filename, content=""):
    basename = os.path.basename(filename)
    match = EBUILD_FILENAME_PATTERN.match(basename)
    if not match:
        return None

    pn = match.group('pn')
    pv = match.group('pv')
    pr = match.group('pr')

    p = f"{pn}-{pv}"
    pr_val = f"r{pr}" if pr else "r0"
    pvr = f"{pv}-r{pr}" if pr else pv
    pf = f"{pn}-{pvr}"

    variables = {
        'PN': pn,
        'PV': pv,
        'P': p,
        'PR': pr_val,
        'PVR': pvr,
        'PF': pf,
    }

    for var_match in re.finditer(r'^[ \t]*([A-Za-z0-9_]+)\s*=\s*["\']([^"\'\n]*)["\']', content, re.MULTILINE):
        key, val = var_match.group(1), var_match.group(2)
        if key not in variables:
            variables[key] = val

    for _ in range(3):
        for k, v in list(variables.items()):
            variables[k] = resolve_variables(v, variables)

    return variables

def resolve_variables(text, variables):
    for key in sorted(variables.keys(), key=len, reverse=True):
        value = variables[key]
        text = text.replace(f"${{{key}}}", value)
        text = text.replace(f"${key}", value)
    return text

def extract_uris(content, variables):
    lines = [line.split('#', 1)[0] for line in content.splitlines()]
    clean_content = '\n'.join(lines)

    match = re.search(r'SRC_URI\s*=\s*"([^"]*)"', clean_content, re.DOTALL)
    if not match:
        match = re.search(r"SRC_URI\s*=\s*'([^']*)'", clean_content, re.DOTALL)

    if not match:
        return []

    src_uri_body = match.group(1)
    src_uri_body = resolve_variables(src_uri_body, variables)

    tokens = src_uri_body.split()

    uris = []
    i = 0
    while i < len(tokens):
        token = tokens[i]

        if '://' in token:
            url = token
            filename = os.path.basename(url)

            if i + 2 < len(tokens) and tokens[i+1] == '->':
                filename = tokens[i+2]
                i += 3
            else:
                i += 1

            uris.append((url, filename))
        else:
            i += 1

    return uris

def upsert_worker(url, filename):
    with tempfile.TemporaryDirectory() as tmpdir:
        temp_path = os.path.join(tmpdir, 'Manifest')
        open(temp_path, 'a').close()

        try:
            subprocess.run(['g2', 'manifest', 'upsert-from-url', url, filename, tmpdir], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

            with open(temp_path, 'r') as f:
                lines = f.readlines()

            return lines
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Upsert failed for {url}: {e}") from e

def process_directory(directory):
    print(f"Processing directory: {directory}")
    manifest_path = os.path.join(directory, 'Manifest')

    ebuilds = [f for f in os.listdir(directory) if f.endswith('.ebuild')]

    if not ebuilds:
        print("No ebuilds found.")
        return

    tasks = []

    for ebuild in ebuilds:
        ebuild_path = os.path.join(directory, ebuild)
        print(f"  Parsing {ebuild}...")

        with open(ebuild_path, 'r') as f:
            content = f.read()

        variables = parse_ebuild_variables(ebuild, content)
        if not variables:
            print(f"  Skipping {ebuild}: Could not parse version/name.")
            continue

        uris = extract_uris(content, variables)
        tasks.extend(uris)

    if not tasks:
        return

    print(f"  Upserting {len(tasks)} URIs in parallel...")

    new_entries = []
    tasks = list(set(tasks))

    with concurrent.futures.ThreadPoolExecutor(max_workers=min(32, len(tasks) + 1)) as executor:
        future_to_url = {executor.submit(upsert_worker, url, filename): (url, filename) for url, filename in tasks}

        for future in concurrent.futures.as_completed(future_to_url):
            url, filename = future_to_url[future]
            try:
                lines = future.result()
                if lines:
                    new_entries.extend(lines)
                    print(f"    Upserted: {url} -> {filename}")
                else:
                    print(f"    Failed to upsert: {url}")
                    sys.exit(1)
            except Exception as e:
                print(f"    Exception processing {url}: {e}")
                sys.exit(1)

    header_lines = []
    dist_lines_map = {}

    if os.path.exists(manifest_path):
        with open(manifest_path, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) > 1 and parts[0] == 'DIST':
                    dist_lines_map[parts[1]] = line
                else:
                    header_lines.append(line)

    for line in new_entries:
        parts = line.strip().split()
        if len(parts) > 1 and parts[0] == 'DIST':
            dist_lines_map[parts[1]] = line

    with tempfile.NamedTemporaryFile('w', delete=False) as tmpf:
        for line in header_lines:
            tmpf.write(line)

        for filename in sorted(dist_lines_map.keys()):
            tmpf.write(dist_lines_map[filename])
        tmpf_name = tmpf.name

    shutil.move(tmpf_name, manifest_path)
    os.chmod(manifest_path, 0o644)

def main():
    if len(sys.argv) < 2:
        print("Usage: verify_manifest.py <directory1> [directory2 ...]")
        sys.exit(1)

    for directory in sys.argv[1:]:
        if os.path.isdir(directory):
            process_directory(directory)
        else:
            print(f"Directory not found: {directory}")
            sys.exit(1)

if __name__ == "__main__":
    main()
