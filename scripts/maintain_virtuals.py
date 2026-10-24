#!/usr/bin/env python3
"""Keep Dart/Flutter virtuals tied to actually packaged, exact-version providers.

Called by source/binary release automation and both sides of scheduled dedupe.
Never asserts that an old SDK is compatible with a newer versioned virtual.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys

PROVIDERS = {
    "dart": ("dev-lang/dart", "dev-lang/dart-bin"),
    "flutter": ("dev-lang/flutter", "dev-lang/flutter-bin"),
}
VERSION = re.compile(r"^(\d+(?:\.\d+){2,})(?:-r(\d+))?\.ebuild$")
PINNED_VIRTUAL = re.compile(
    r"(?:~|=)virtual/(dart|flutter)-(\d+(?:\.\d+){2,})(?:-r\d+)?"
)


def parsed_version(filename: str, package: str):
    prefix = package + "-"
    if not filename.startswith(prefix):
        return None
    match = VERSION.fullmatch(filename[len(prefix):])
    if not match:
        return None
    return match.group(1), int(match.group(2) or "0")


def version_key(version: str):
    return tuple(int(part) for part in version.split("."))


def matching_ebuilds(root: Path, package_dir: str, version: str):
    directory = root / package_dir
    name = directory.name
    return sorted(
        p for p in directory.glob("*.ebuild")
        if (parsed := parsed_version(p.name, name)) and parsed[0] == version
    )


def available_providers(root: Path, package: str, version: str):
    return [
        directory for directory in PROVIDERS[package]
        if matching_ebuilds(root, directory, version)
    ]


def provider_keywords(root: Path, providers: list[str], version: str):
    keywords = set()
    for directory in providers:
        for path in matching_ebuilds(root, directory, version):
            match = re.search(r'^KEYWORDS="([^"]+)"', path.read_text(), re.M)
            if match is None:
                raise ValueError(f"missing KEYWORDS in {path}")
            keywords.update(match.group(1).split())
    if not keywords:
        raise ValueError("no keyworded virtual providers")
    return " ".join(sorted(keywords))


def virtual_content(root: Path, package: str, version: str):
    providers = available_providers(root, package, version)
    if not providers:
        raise ValueError(f"no real provider for virtual/{package}-{version}")
    keywords = provider_keywords(root, providers, version)
    alternatives = "\n".join(
        f"\t~{directory}-{version}" for directory in providers
    )
    return (
        "# Copyright 2026 Gentoo Authors\n"
        "# Distributed under the terms of the GNU General Public License v2\n\n"
        "EAPI=8\n\n"
        f'DESCRIPTION="Virtual for the {package.title()} SDK"\n\n'
        'SLOT="0"\n'
        f'KEYWORDS="{keywords}"\n\n'
        f'RDEPEND="|| (\n{alternatives}\n)"\n'
    )


def ensure_virtual(root: Path, package: str, version: str):
    """Create/revise an exact-version virtual, retaining existing ebuild bytes."""
    if package not in PROVIDERS or not re.fullmatch(r"\d+(?:\.\d+){2,}", version):
        raise ValueError(f"invalid virtual target {package}-{version}")
    expected = virtual_content(root, package, version)
    directory = root / "virtual" / package
    directory.mkdir(parents=True, exist_ok=True)
    existing = matching_ebuilds(root, f"virtual/{package}", version)
    if existing and any(path.read_text() == expected for path in existing):
        return None
    revision = max((parsed_version(p.name, package)[1] for p in existing), default=-1) + 1
    suffix = "" if revision == 0 else f"-r{revision}"
    path = directory / f"{package}-{version}{suffix}.ebuild"
    if path.exists():
        raise ValueError(f"refusing to overwrite {path}")
    path.write_text(expected)
    return path


def all_versions(root: Path, package: str):
    versions = set()
    for directory in PROVIDERS[package]:
        name = directory.split("/")[-1]
        for path in (root / directory).glob("*.ebuild"):
            parsed = parsed_version(path.name, name)
            if parsed:
                versions.add(parsed[0])
    return sorted(versions, key=version_key)


def prepare(root: Path):
    """Publish a new virtual whenever at least one version-matched provider exists."""
    for package in PROVIDERS:
        versions = all_versions(root, package)
        if versions:
            ensure_virtual(root, package, versions[-1])


def pinned_virtual_consumers(root: Path, package: str, version: str):
    consumers = []
    for path in root.glob("*/*/*.ebuild"):
        if path.parent == root / "virtual" / package:
            continue
        for match in PINNED_VIRTUAL.finditer(path.read_text()):
            if match.group(1) == package and match.group(2) == version:
                consumers.append(str(path.relative_to(root)))
    return consumers


def cleanup(root: Path):
    """After dedupe, refresh outdated alternatives and retire orphaned virtuals.

    Orphan removal needs a newer viable virtual, and refuses exact-pinned users.
    A missing or unsupported provider never becomes an invented dependency.
    """
    for package in PROVIDERS:
        directory = root / "virtual" / package
        old = sorted(directory.glob("*.ebuild"))
        existing_versions = {
            parsed[0] for p in old
            if (parsed := parsed_version(p.name, package))
        }
        live_versions = set(all_versions(root, package))
        newest_live = max(live_versions, key=version_key) if live_versions else None
        if not newest_live:
            raise ValueError(f"no viable providers for virtual/{package}")
        ensure_virtual(root, package, newest_live)
        for version in sorted(existing_versions, key=version_key):
            paths = matching_ebuilds(root, f"virtual/{package}", version)
            if version not in live_versions:
                if version_key(version) >= version_key(newest_live):
                    raise ValueError(f"no newer provider replaces virtual/{package}-{version}")
                consumers = pinned_virtual_consumers(root, package, version)
                if consumers:
                    raise ValueError(
                        f"cannot retire pinned virtual/{package}-{version}: "
                        + ", ".join(consumers)
                    )
                for path in paths:
                    path.unlink()
                continue
            # A source-only or binary-only surviving version must not keep an
            # obsolete alternative in the active virtual revision.
            revised = ensure_virtual(root, package, version)
            if revised:
                consumers = pinned_virtual_consumers(root, package, version)
                if consumers:
                    raise ValueError(
                        f"cannot revise pinned virtual/{package}-{version}: "
                        + ", ".join(consumers)
                    )
                for path in paths:
                    path.unlink()
        for path in directory.glob("*.ebuild"):
            parsed = parsed_version(path.name, package)
            if not parsed:
                raise ValueError(f"unrecognised virtual ebuild: {path}")
            if not available_providers(root, package, parsed[0]):
                raise ValueError(f"unsatisfied virtual left behind: {path}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("ensure", "prepare", "cleanup"))
    parser.add_argument("root", type=Path)
    parser.add_argument("package", nargs="?")
    parser.add_argument("version", nargs="?")
    args = parser.parse_args()
    try:
        if args.action == "ensure":
            if not args.package or not args.version:
                parser.error("ensure requires package and version")
            ensure_virtual(args.root, args.package, args.version)
        elif args.action == "prepare":
            prepare(args.root)
        else:
            cleanup(args.root)
    except ValueError as error:
        print(f"virtual reconciliation refused: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
