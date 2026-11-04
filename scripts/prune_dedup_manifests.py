#!/usr/bin/env python3
"""Prune only provably unused DIST entries after ebuild deduplication.

Keep original hashes and all non-DIST metadata verbatim. No network access or
g2 manifest clean; unknown SRC_URI constructs fail closed instead of guessing.
"""
from __future__ import annotations

from pathlib import Path
import re
import subprocess
import sys

from verify_manifest import parse_ebuild_variables, extract_uris


def prune_package(directory: Path) -> bool:
    manifest = directory / "Manifest"
    if not manifest.exists():
        raise ValueError(f"missing Manifest: {manifest}")
    ebuilds = sorted(directory.glob("*.ebuild"))
    if not ebuilds:
        raise ValueError(f"cannot prune last ebuild: {directory}")
    required = set()
    for ebuild in ebuilds:
        content = ebuild.read_text()
        variables = parse_ebuild_variables(ebuild.name, content)
        if variables is None:
            raise ValueError(f"cannot parse ebuild: {ebuild}")
        if re.search(r"\bSRC_URI\s*=", content) and not extract_uris(content, variables):
            raise ValueError(f"cannot resolve SRC_URI in {ebuild}")
        for _, name in extract_uris(content, variables):
            if not name or "$" in name or "{" in name or "/" in name:
                raise ValueError(f"unresolved DIST name in {ebuild}: {name}")
            required.add(name)
    original = manifest.read_text()
    retained = []
    present = set()
    for line in original.splitlines(keepends=True):
        parts = line.split()
        if parts and parts[0] == "DIST":
            if len(parts) < 5:
                raise ValueError(f"malformed DIST entry in {manifest}: {line!r}")
            if parts[1] in required:
                retained.append(line)
                present.add(parts[1])
        else:
            retained.append(line)
    missing = required - present
    if missing:
        raise ValueError(f"missing DIST entries in {manifest}: {sorted(missing)}")
    updated = "".join(retained)
    if updated != original:
        manifest.write_text(updated)
        return True
    return False


def main(root: Path):
    diff = subprocess.check_output(
        ["git", "diff", "--name-only", "--diff-filter=D", "HEAD", "--", "*.ebuild"],
        cwd=root, text=True,
    )
    changed = sorted({(root / path).parent for path in diff.splitlines()})
    for package in changed:
        if prune_package(package):
            print(f"Pruned unreferenced DIST entries in {package.relative_to(root)}")


if __name__ == "__main__":
    try:
        main(Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve())
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"dedupe manifest reconciliation refused: {error}", file=sys.stderr)
        sys.exit(1)
