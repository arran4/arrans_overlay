#!/usr/bin/env python3
"""Reject package payload changes which cannot trigger a Portage upgrade."""
import re
import subprocess
import sys
from pathlib import PurePosixPath

PV_RE = re.compile(r"^(\d+(?:\.\d+)*)([a-z]?)(.*)$")
SUFFIX_RE = re.compile(r"_(alpha|beta|pre|rc|p)(\d*)")
RANK = {"alpha": -4, "beta": -3, "pre": -2, "rc": -1, "p": 1}

def version_key(filename, package):
    prefix = f"{package}-"
    if not filename.startswith(prefix) or not filename.endswith(".ebuild"):
        return None
    version = filename[len(prefix):-7]
    revision = 0
    rev = re.search(r"-r(\d+)$", version)
    if rev:
        revision = int(rev.group(1))
        version = version[:rev.start()]
    match = PV_RE.fullmatch(version)
    if not match:
        return None
    numeric, letter, suffix = match.groups()
    parts = list(SUFFIX_RE.finditer(suffix))
    if "".join(m.group() for m in parts) != suffix:
        return None
    numbers = tuple(int(n) for n in numeric.split("."))
    numbers += (0,) * max(0, 32 - len(numbers))
    letter_rank = ord(letter) - ord("a") - 26 if letter else 0
    suffixes = tuple((RANK[m.group(1)], int(m.group(2) or 0)) for m in parts)
    return numbers, letter_rank, suffixes + ((0, 0),), revision

def package_path(path):
    parts = PurePosixPath(path).parts
    if len(parts) < 3 or parts[0].startswith("."):
        return None
    if not re.fullmatch(r"[a-zA-Z0-9+_.-]+", parts[0]):
        return None
    return "/".join(parts[:2]), "/".join(parts[2:])

def ebuild_keys(paths, directory):
    name = directory.split("/")[1]
    prefix = directory + "/"
    return [(p, version_key(p[len(prefix):], name))
            for p in paths if p.startswith(prefix) and p.endswith(".ebuild")
            and "/" not in p[len(prefix):]]

def validate(base_paths, head_paths, changed_paths):
    base_paths, head_paths = set(base_paths), set(head_paths)
    failures, payload_changed = [], set()
    for path in sorted(set(changed_paths)):
        parsed = package_path(path)
        if not parsed:
            continue
        directory, relative = parsed
        if relative.endswith(".ebuild") and path in base_paths and path in head_paths:
            failures.append(f"{path}: existing ebuild modified; preserve it and create a new version or -rN")
        if relative.startswith("files/"):
            payload_changed.add(directory)
    for directory in sorted(payload_changed):
        previous = ebuild_keys(base_paths, directory)
        current = ebuild_keys(head_paths, directory)
        if not previous or not current:
            continue  # newly introduced or removed package
        added = [(p, v) for p, v in current if p not in base_paths]
        if not added:
            failures.append(f"{directory}/files/: payload changed without any new ebuild")
            continue
        if any(v is None for _, v in previous + added):
            failures.append(f"{directory}: unrecognised version; manually check the CPV ordering")
            continue
        # A live 9999 ebuild must not mask revisions of packaged releases.
        normal_old = [(p,v) for p,v in previous if not re.search(r"-9999(?:-r\d+)?\.ebuild$", p)]
        normal_new = [(p,v) for p,v in added if not re.search(r"-9999(?:-r\d+)?\.ebuild$", p)]
        if normal_new and not normal_old:
            continue  # first stable version beside a live-only ebuild
        old_keys = [v for _,v in (normal_old or previous)]
        new_keys = [v for _,v in (normal_new or added)]
        if max(new_keys) <= max(old_keys):
            failures.append(f"{directory}: new ebuild must have a higher version or revision")
    return failures

def git(*args):
    return subprocess.check_output(["git", *args], text=True).splitlines()

def main(argv):
    if len(argv) != 4 or argv[3] not in {"pr", "push"}:
        print("usage: check_ebuild_revisions.py BASE_SHA HEAD_SHA pr|push", file=sys.stderr)
        return 2
    base, head, mode = argv[1:]
    if not base or set(base) == {"0"}:
        print("Initial push without base; skipping revision guard")
        return 0
    before = git("ls-tree", "-r", "--name-only", base)
    after = git("ls-tree", "-r", "--name-only", head)
    diff = f"{base}...{head}" if mode == "pr" else f"{base}..{head}"
    failures = validate(before, after, git("diff", "--no-renames", "--name-only", diff))
    for failure in failures:
        print(f"::error::{failure}", file=sys.stderr)
    print("Ebuild revision guard " + ("failed" if failures else "passed"))
    return 1 if failures else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
