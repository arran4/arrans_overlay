#!/usr/bin/env python3
import os
import re
import hashlib
import concurrent.futures
from collections import defaultdict


_VERSION_PART_RE = re.compile(r"(\d+|[a-zA-Z]+|[^a-zA-Z\d]+)")
_EBUILD_PATTERN = re.compile(r"(.+)-([0-9][^/]*)\.ebuild$")


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


def parse_slot(lines):
    slot = "0"
    for line in lines:
        line = line.strip()
        if line.startswith("SLOT="):
            slot = line.split("=", 1)[1].strip().strip('"').strip("'")
            break
    return slot


def digest(lines):
    content = []
    for line in lines:
        if line.lstrip().startswith("# Generated via:"):
            continue
        content.append(line)
    data = "".join(content).encode()
    return hashlib.md5(data).hexdigest()


def process_ebuild(args):
    root, file = args
    if not file.endswith(".ebuild"):
        return None

    path = os.path.join(root, file)
    m = _EBUILD_PATTERN.match(file)
    if not m:
        return None

    try:
        with open(path, "r", errors="ignore") as f:
            lines = f.readlines()
    except OSError:
        return None

    slot = parse_slot(lines)
    try:
        ver, rev = split_ebuild_name(file)
    except ValueError:
        return None

    full_ver = ver if rev == "r0" else f"{ver}-{rev}"
    grade = "release"
    v_lower = ver.lower()
    if ver == "9999":
        grade = "9999"
    else:
        for tag in ("alpha", "beta", "rc", "pre", "test"):
            if tag in v_lower:
                grade = tag
                break

    return ((root, slot), grade, {
        "version": full_ver,
        "path": path,
        "digest": digest(lines),
    })


def main(repo_root):
    packages = defaultdict(lambda: defaultdict(list))

    file_tasks = []
    for root, dirs, files in os.walk(repo_root):
        for file in files:
            if file.endswith(".ebuild"):
                file_tasks.append((root, file))

    # Use ProcessPoolExecutor for parallel processing
    # Adjust max_workers as needed, usually default is fine (number of processors)
    with concurrent.futures.ProcessPoolExecutor() as executor:
        # chunksize helps with many small tasks
        results = executor.map(process_ebuild, file_tasks, chunksize=100)

    for result in results:
        if result:
            key, grade, item = result
            packages[key][grade].append(item)

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

    def cleanup(pkg_dir):
        import subprocess
        try:
            entries = os.listdir(pkg_dir)
        except FileNotFoundError:
            return

        manifest = os.path.join(pkg_dir, "Manifest")
        ebuilds = {entry for entry in entries if entry.endswith(".ebuild")}

        if ebuilds:
            if os.path.exists(manifest):
                try:
                    subprocess.run(["g2", "manifest", "clean", pkg_dir], capture_output=True, check=False)
                except FileNotFoundError:
                    pass
        else:
            if os.path.exists(manifest):
                os.remove(manifest)
            try:
                os.rmdir(pkg_dir)
            except OSError:
                pass

    if removed:
        for pkg_dir in {os.path.dirname(p) for p in removed}:
            cleanup(pkg_dir)
        print("Removed duplicate ebuilds:")

        grouped_removed = defaultdict(list)
        for p in removed:
            rel_p = os.path.relpath(p, repo_root)
            parts = rel_p.split(os.sep)
            if len(parts) >= 3:
                cat = parts[-3]
                pkg = parts[-2]
                ebuild_file = parts[-1]
                if ebuild_file.startswith(pkg + '-'):
                    ver_part = ebuild_file[len(pkg) + 1:-7]
                    grouped_removed[f"{cat}/{pkg}"].append(ver_part)
                else:
                    grouped_removed[f"{cat}/{pkg}"].append(ebuild_file)
            else:
                grouped_removed["unknown"].append(rel_p)

        grouped_remaining = defaultdict(list)
        removed_set = set(removed)
        for (pkg_root, slot), grades in packages.items():
            rel_p = os.path.relpath(pkg_root, repo_root)
            parts = rel_p.split(os.sep)
            if len(parts) >= 2:
                cat = parts[-2]
                pkg = parts[-1]
                pkg_name = f"{cat}/{pkg}"
                if pkg_name in grouped_removed:
                    for grade, items in grades.items():
                        for itm in items:
                            if itm["path"] not in removed_set:
                                file_name = os.path.basename(itm["path"])
                                if file_name.startswith(pkg + '-'):
                                    ver_part = file_name[len(pkg) + 1:-7]
                                    grouped_remaining[pkg_name].append(ver_part)
                                else:
                                    grouped_remaining[pkg_name].append(file_name)

        for pkg, vers in grouped_removed.items():
            rem_vers = grouped_remaining.get(pkg, [])

            normal_rem_vers = [v for v in rem_vers if v.split('-r')[0] != "9999"]
            has_9999 = any(v.split('-r')[0] == "9999" for v in rem_vers)

            formatted_removed = ', '.join(
                f"-{v}" if not v.startswith('-') else v
                for v in sorted(set(vers), key=version_key)
            )

            formatted_remaining = ', '.join(sorted(set(normal_rem_vers), key=version_key))

            live_note = " [has live 9999]" if has_9999 else ""

            if formatted_remaining:
                print(f" - {pkg} (Removed: {formatted_removed} | Remaining: {formatted_remaining}){live_note}")
            else:
                print(f" - {pkg} (Removed: {formatted_removed} | Remaining: None){live_note}")
    else:
        print("No duplicates found")

if __name__ == "__main__":
    main(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
