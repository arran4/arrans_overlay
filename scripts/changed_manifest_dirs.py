#!/usr/bin/env python3
"""Select existing package Manifests affected by a Git diff.

Deletion of a whole package is intentionally skipped. Deletion of a Manifest
while ebuilds remain is an error, not an excuse to skip verification.
"""
import argparse
import os
from pathlib import Path
import re
import subprocess
import sys

PACKAGE_MANIFEST = re.compile(r"[A-Za-z0-9+_.-]+/[A-Za-z0-9+_.-]+/Manifest\Z")


def changed_manifest_dirs(base, head, *, three_dot=False, cwd="."):
    root = Path(cwd)
    revision = f"{base}...{head}" if three_dot else f"{base}..{head}"
    result = subprocess.run(
        ["git", "diff", "--no-renames", "--name-only", "-z",
         revision, "--", ":(glob)**/Manifest"],
        cwd=root,
        check=True,
        stdout=subprocess.PIPE,
    )
    directories = set()
    for raw_path in result.stdout.split(b"\0"):
        if not raw_path:
            continue
        relative = os.fsdecode(raw_path)
        if not PACKAGE_MANIFEST.fullmatch(relative):
            continue

        package_dir = root / relative.rsplit("/", 1)[0]
        manifest = package_dir / "Manifest"
        has_ebuilds = package_dir.is_dir() and any(package_dir.glob("*.ebuild"))

        if manifest.is_file() and has_ebuilds:
            directories.add(relative.rsplit("/", 1)[0])
        elif has_ebuilds:
            raise ValueError(
                f"Manifest was deleted but ebuilds remain in {package_dir}"
            )
        elif manifest.is_file():
            raise ValueError(
                f"Orphan Manifest with no ebuilds in {package_dir}"
            )
        else:
            print(f"Skipping removed package Manifest: {relative}", file=sys.stderr)

    return sorted(directories)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("base", help="Git base revision")
    parser.add_argument("head", help="Git head revision")
    parser.add_argument(
        "--three-dot",
        action="store_true",
        help="Compare the merge-base with head (pull requests)",
    )
    args = parser.parse_args()
    try:
        print(" ".join(changed_manifest_dirs(
            args.base, args.head, three_dot=args.three_dot
        )))
    except (ValueError, subprocess.CalledProcessError) as exc:
        parser.exit(1, f"Manifest selection failed: {exc}\n")


if __name__ == "__main__":
    main()
