#!/usr/bin/env python3
"""Shared helpers for source-package update automation."""

from __future__ import annotations

import re
import shutil
from pathlib import Path

_FILESDIR_REF_RE = re.compile(r'\$\{FILESDIR\}/([^"\'\s)]+)')
_VERSIONED_TOKENS = ("${PV}", "${P}", "${PVR}", "${PF}")


def _values(package_name: str, pvr: str) -> dict[str, str]:
    pv = re.sub(r"-r\d+$", "", pvr)
    return {
        "PN": package_name,
        "PV": pv,
        "P": f"{package_name}-{pv}",
        "PVR": pvr,
        "PF": f"{package_name}-{pvr}",
    }


def _expand(reference: str, values: dict[str, str]) -> str:
    expanded = reference
    for key, value in values.items():
        expanded = expanded.replace(f"${{{key}}}", value)
    if "${" in expanded:
        raise ValueError(f"Unsupported variable in FILESDIR reference: {reference}")
    return expanded


def carry_forward_versioned_files(
    previous_ebuild: Path,
    new_version: str,
    source_root: Path,
    work_root: Path,
    package: str,
) -> list[str]:
    """Copy version-qualified FILESDIR assets referenced by an ebuild.

    Only references containing PV/P/PVR/PF are copied. Unversioned shared
    assets remain shared in-place. Existing destination files must be byte-
    identical or the update fails closed.
    """

    package_name = package.rsplit("/", 1)[-1]
    prefix = f"{package_name}-"
    stem = previous_ebuild.stem
    if not stem.startswith(prefix):
        raise ValueError(
            f"{previous_ebuild.name} does not belong to package {package}"
        )

    old_pvr = stem.removeprefix(prefix)
    old_values = _values(package_name, old_pvr)
    new_values = _values(package_name, new_version)

    references = sorted(set(_FILESDIR_REF_RE.findall(previous_ebuild.read_text())))
    carried: list[str] = []

    for reference in references:
        if not any(token in reference for token in _VERSIONED_TOKENS):
            continue

        source_name = _expand(reference, old_values)
        destination_name = _expand(reference, new_values)
        source = source_root / package / "files" / source_name
        destination = work_root / package / "files" / destination_name

        if not source.is_file():
            raise FileNotFoundError(
                f"Versioned FILESDIR asset referenced by {previous_ebuild.name} "
                f"is missing: {source}"
            )

        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists():
            if destination.read_bytes() != source.read_bytes():
                raise FileExistsError(
                    f"Refusing to overwrite differing carried asset: {destination}"
                )
        else:
            shutil.copy2(source, destination)

        carried.append(f"{package}/files/{destination_name}")

    return carried
