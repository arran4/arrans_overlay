#!/usr/bin/env python3
import os
import re
import hashlib
from packaging.version import parse as parse_version
from collections import defaultdict

def parse_slot(path):
    slot = "0"
    try:
        with open(path, "r", errors="ignore") as f:
            for line in f:
                line = line.strip()
                if line.startswith("SLOT="):
                    slot = line.split("=", 1)[1].strip().strip('"').strip("'")
                    break
    except FileNotFoundError:
        pass
    return slot


def main(repo_root):
    pattern = re.compile(r"(.+)-([0-9][^/]*)\.ebuild$")
    groups = defaultdict(list)
    for root, dirs, files in os.walk(repo_root):
        for file in files:
            if not file.endswith(".ebuild"):
                continue
            path = os.path.join(root, file)
            m = pattern.match(file)
            if not m:
                continue
            version = m.group(2)
            slot = parse_slot(path)
            with open(path, "rb") as fh:
                digest = hashlib.md5(fh.read()).hexdigest()
            groups[(root, slot, digest)].append((parse_version(version), path))
    removed = []
    for (root, slot, digest), items in groups.items():
        if len(items) <= 1:
            continue
        items.sort(key=lambda x: x[0])
        for _, p in items[:-1]:
            os.remove(p)
            removed.append(p)
    if removed:
        print("Removed duplicated ebuilds:")
        for p in removed:
            print(" -", p)
    else:
        print("No duplicates found")

if __name__ == "__main__":
    main(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
