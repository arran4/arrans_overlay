"""Helpers for tests that inspect the overlay's currently packaged ebuilds."""

import re
from pathlib import Path


def latest_versioned_ebuild(package_dir: Path) -> Path:
    """Select the highest real PV and -rN from this package's ebuilds.

    Tests which inspect actual overlay files must survive scheduled removal
    of superseded versions; an empty package remains a test failure.
    """
    package = package_dir.name
    pattern = re.compile(
        rf"{re.escape(package)}-(\d+(?:\.\d+){{2,}})(?:-r(\d+))?\.ebuild"
    )
    candidates = []
    for path in package_dir.glob(f"{package}-*.ebuild"):
        match = pattern.fullmatch(path.name)
        if match:
            pv = tuple(int(part) for part in match.group(1).split("."))
            revision = int(match.group(2) or 0)
            candidates.append(((pv, revision), path))
    if not candidates:
        raise FileNotFoundError(f"no versioned {package} ebuild in {package_dir}")
    return max(candidates, key=lambda item: item[0])[1]
