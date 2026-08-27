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
CAELESTIA_BINARY_EXCLUDES = (
    "gui-apps/quickshell",
    "gui-apps/caelestia-shell",
    "gui-apps/caelestia-meta",
)
PYTHON_PACKAGES = {"dev-python/materialyoucolor"}
FONT_PACKAGES = {
    "media-fonts/material-symbols-variable",
    "media-fonts/rubik",
}
FORCE_CAELESTIA_PATHS = {
    ".github/workflows/gentoo-pkg-test.yml",
    ".github/scripts/determine_packages.py",
}


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
    package_or_cpv = atom.removeprefix("=")
    known_packages = (*CORE_PACKAGES, *PYTHON_PACKAGES, *FONT_PACKAGES)
    if package_or_cpv in known_packages:
        return package_or_cpv

    category, package_version = package_or_cpv.split("/", 1)
    for package in known_packages:
        package_category, package_name = package.split("/", 1)
        if category == package_category and package_version.startswith(f"{package_name}-"):
            return package
    return None


def cache_id(group, package):
    canonical = f"{group}\n{package}".encode()
    return hashlib.sha256(canonical).hexdigest()[:16]


def matrix_entry(group, package, source_target):
    return {
        "group": group,
        "package": package,
        "source_target": source_target,
        "binary_excludes": " ".join(CAELESTIA_BINARY_EXCLUDES) if group == "caelestia-core" else "",
        "cache_id": cache_id(group, package),
    }


def build_matrix(changed_files, source_files=()):
    normalized_files = {normalize_path(path) for path in changed_files}
    source_atoms = {
        atom
        for path in source_files
        if (atom := atom_from_path(path)) is not None
    }
    grouped = {
        "caelestia-core": set(),
        "caelestia-python": set(),
        "caelestia-fonts": set(),
        "generic": set(),
    }

    if normalized_files & FORCE_CAELESTIA_PATHS:
        # Unversioned atoms let Portage select the latest visible ebuild using
        # Gentoo version semantics rather than unreliable filename sorting.
        grouped["caelestia-core"].update(CORE_PACKAGES)

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
            package_atoms = sorted(atom for atom in core_atoms if cp_from_atom(atom) == package)
            versioned_atoms = [atom for atom in package_atoms if atom != package]
            # Forced integration coverage contributes an unversioned atom. If
            # the same package has a directly changed ebuild, test that exact
            # CPV instead of creating a duplicate integration job.
            ordered_core.extend(versioned_atoms or package_atoms)
        matrix.extend(
            matrix_entry("caelestia-core", package, package in source_atoms)
            for package in ordered_core
        )

    for group in ("caelestia-python", "caelestia-fonts"):
        matrix.extend(
            matrix_entry(group, package, package in source_atoms)
            for package in sorted(grouped[group])
        )

    matrix.extend(
        matrix_entry("generic", package, package in source_atoms)
        for package in sorted(grouped["generic"])
    )

    return matrix


if __name__ == "__main__":
    print(json.dumps(build_matrix(
        os.environ.get("CHANGED_FILES", "").split(),
        os.environ.get("SOURCE_FILES", "").split(),
    )))
