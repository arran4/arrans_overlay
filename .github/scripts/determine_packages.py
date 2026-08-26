#!/usr/bin/env python3

import hashlib
import json
import os
from pathlib import Path


CORE_PACKAGES = (
    "gui-apps/quickshell",
    "gui-apps/caelestia-shell",
    "gui-apps/caelestia-cli",
    "gui-apps/caelestia-meta",
)
PYTHON_PACKAGES = {"dev-python/materialyoucolor"}
FONT_PACKAGES = {
    "media-fonts/material-symbols-variable",
    "media-fonts/rubik",
}
FORCE_CAElESTIA_PATHS = {
    ".github/workflows/gentoo-pkg-test.yml",
    ".github/scripts/determine_packages.py",
}
GENERIC_CHUNK_SIZE = 10


def normalize_path(path):
    while path.startswith("./"):
        path = path[2:]
    return path


def atom_from_path(path):
    parts = Path(normalize_path(path)).parts
    if len(parts) != 3 or not parts[2].endswith(".ebuild"):
        return None
    return f"={parts[0]}/{parts[2][:-7]}"


def cp_from_atom(atom):
    versioned_name = atom.removeprefix("=")
    category, package_version = versioned_name.split("/", 1)
    for package in (*CORE_PACKAGES, *PYTHON_PACKAGES, *FONT_PACKAGES):
        package_category, package_name = package.split("/", 1)
        if category == package_category and package_version.startswith(f"{package_name}-"):
            return package
    return None


def latest_atom(package):
    category, package_name = package.split("/", 1)
    ebuilds = sorted(Path(category, package_name).glob(f"{package_name}-*.ebuild"))
    if not ebuilds:
        raise FileNotFoundError(f"No ebuild found for forced package {package}")
    return atom_from_path(str(ebuilds[-1]))


def cache_id(packages):
    canonical = "\n".join(sorted(packages)).encode()
    return hashlib.sha256(canonical).hexdigest()[:16]


def matrix_entry(group, packages):
    return {
        "group": group,
        "packages": " ".join(packages),
        "cache_id": cache_id(packages),
    }


def build_matrix(changed_files):
    normalized_files = {normalize_path(path) for path in changed_files}
    grouped = {
        "caelestia-core": set(),
        "caelestia-python": set(),
        "caelestia-fonts": set(),
        "generic": set(),
    }

    if normalized_files & FORCE_CAElESTIA_PATHS:
        grouped["caelestia-core"].update(latest_atom(package) for package in CORE_PACKAGES)

    for path in normalized_files:
        atom = atom_from_path(path)
        if atom is None:
            continue
        package = cp_from_atom(atom)
        if package in CORE_PACKAGES:
            grouped["caelestia-core"].add(atom)
        elif package in PYTHON_PACKAGES:
            grouped["caelestia-python"].add(atom)
        elif package in FONT_PACKAGES:
            grouped["caelestia-fonts"].add(atom)
        else:
            grouped["generic"].add(atom)

    matrix = []
    core_atoms = grouped["caelestia-core"]
    if core_atoms:
        ordered_core = []
        for package in CORE_PACKAGES:
            ordered_core.extend(sorted(atom for atom in core_atoms if cp_from_atom(atom) == package))
        matrix.append(matrix_entry("caelestia-core", ordered_core))

    for group in ("caelestia-python", "caelestia-fonts"):
        if grouped[group]:
            matrix.append(matrix_entry(group, sorted(grouped[group])))

    generic_atoms = sorted(grouped["generic"])
    for offset in range(0, len(generic_atoms), GENERIC_CHUNK_SIZE):
        chunk = generic_atoms[offset:offset + GENERIC_CHUNK_SIZE]
        matrix.append(matrix_entry(f"generic-{offset // GENERIC_CHUNK_SIZE}", chunk))

    return matrix


if __name__ == "__main__":
    print(json.dumps(build_matrix(os.environ.get("CHANGED_FILES", "").split())))
