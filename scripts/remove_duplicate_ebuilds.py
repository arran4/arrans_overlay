#!/usr/bin/env python3
import os
import re
import hashlib
from collections import defaultdict


_VERSION_PART_RE = re.compile(r"(\d+|[a-zA-Z]+|[^a-zA-Z\d]+)")


def split_ebuild_name(filename):
    stem = filename[:-7]
    match = re.match(r"^(?P<name>.+)-(?P<ver>[0-9].*)$", stem)
    if not match:
        raise ValueError(f"Unable to parse ebuild name: {filename}")
    ver_rev = match.group("ver")
    revision = "r0"
    version = ver_rev
    if "-r" in ver_rev:
        ver_candidate, rev_candidate = ver_rev.rsplit("-r", 1)
        if rev_candidate.isdigit():
            version = ver_candidate
            revision = f"r{rev_candidate}"
    return version, revision


def version_key(version):
    parts = []
    for segment in re.split(r"[._-]", version):
        if not segment:
            continue
        for token in _VERSION_PART_RE.findall(segment):
            if token.isdigit():
                parts.append((0, int(token)))
            else:
                parts.append((1, token))
    return tuple(parts)

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
    packages = defaultdict(lambda: defaultdict(list))

    def digest(path):
        with open(path, "r", errors="ignore") as fh:
            content = []
            for line in fh:
                if line.lstrip().startswith("# Generated via:"):
                    continue
                content.append(line)
            data = "".join(content).encode()
            return hashlib.md5(data).hexdigest()

    for root, dirs, files in os.walk(repo_root):
        for file in files:
            if not file.endswith(".ebuild"):
                continue
            path = os.path.join(root, file)
            m = pattern.match(file)
            if not m:
                continue
            slot = parse_slot(path)
            try:
                ver, rev = split_ebuild_name(file)
            except ValueError:
                continue
            full_ver = ver if rev == "r0" else f"{ver}-{rev}"
            grade = "release"
            v_lower = ver.lower()
            for tag in ("alpha", "beta", "rc", "pre", "test"):
                if tag in v_lower:
                    grade = tag
                    break
            packages[(root, slot)][grade].append({
                "version": full_ver,
                "path": path,
                "digest": digest(path),
            })

    removed = []
    # remove identical files based on digest
    for (pkg_root, slot), grades in packages.items():
        for grade, items in grades.items():
            digest_groups = defaultdict(list)
            for item in items:
                digest_groups[item["digest"]].append(item)
            for dg_items in digest_groups.values():
                if len(dg_items) <= 1:
                    continue
                dg_items.sort(key=lambda x: version_key(x["version"]))
                for itm in dg_items[:-1]:
                    os.remove(itm["path"])
                    removed.append(itm["path"])
                items[:] = [dg_items[-1]] + [i for i in items if i not in dg_items]

    # remove older versions within same grade
    for (pkg_root, slot), grades in packages.items():
        for grade, items in grades.items():
            if len(items) <= 1:
                continue
            items.sort(key=lambda x: version_key(x["version"]))
            for itm in items[:-1]:
                if itm["path"] not in removed:
                    os.remove(itm["path"])
                    removed.append(itm["path"])

    def cleanup(path):
        pkg_dir = os.path.dirname(path)
        manifest = os.path.join(pkg_dir, "Manifest")
        basename = os.path.basename(path)
        if os.path.exists(manifest):
            with open(manifest, "r") as f:
                lines = f.readlines()
            new_lines = [l for l in lines if basename not in l]
            if new_lines:
                with open(manifest, "w") as f:
                    f.writelines(new_lines)
            else:
                os.remove(manifest)
        if not any(f.endswith(".ebuild") for f in os.listdir(pkg_dir)):
            if os.path.exists(manifest):
                os.remove(manifest)
            os.rmdir(pkg_dir)

    if removed:
        for p in removed:
            cleanup(p)
        print("Removed duplicated ebuilds:")
        for p in removed:
            print(" -", p)
    else:
        print("No duplicates found")

if __name__ == "__main__":
    main(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
