#!/usr/bin/env python3
"""Shared helpers for source-package update automation."""

from __future__ import annotations

import re
import shutil
from dataclasses import dataclass
from pathlib import Path

_FILESDIR_REF_RE = re.compile(r'\$\{FILESDIR\}/([^"\'\s)]+)')
_VERSIONED_TOKENS = ("${PV}", "${P}", "${PVR}", "${PF}")
_PATCH_FILENAME_RE = re.compile(
    r"^(?P<stem>.+?)(?:-r(?P<revision>[1-9][0-9]*))?\.patch$"
)
_SERIES_RE = re.compile(r"^(?P<series>[0-9]+(?:\.[0-9]+)+)-(?P<family>.+)$")


@dataclass(frozen=True)
class PatchFilename:
    """An immutable patch-file identity, distinct from an ebuild revision."""

    filename: str
    family: str
    series: str | None
    revision: int | None
    package_name: str | None = None

    @property
    def is_legacy(self) -> bool:
        """Whether this name predates the required immutable ``-rN`` suffix."""

        return self.revision is None

    def canonical_filename(self) -> str:
        """Return the immutable filename used by newly generated ebuilds.

        If a series qualifier is present (including a version-like sequence
        from legacy unversioned filenames such as ``dart-3.13.3-fix.patch``),
        it is preserved conservatively as a series qualifier (e.g.
        ``dart-3.13.3-fix-r1.patch``) rather than being heuristically stripped.
        This avoids accidental collision between version-specific legacy
        patches and preserves the patch's distinct identity.
        """

        if self.series and self.package_name:
            package_prefix = f"{self.package_name}-"
            if self.family.startswith(package_prefix):
                return (
                    f"{package_prefix}{self.series}-"
                    f"{self.family.removeprefix(package_prefix)}"
                    f"-r{self.revision or 1}.patch"
                )
        return f"{self.family}-r{self.revision or 1}.patch"


def parse_patch_filename(filename: str, package_name: str | None = None) -> PatchFilename:
    """Parse a patch filename without confusing patch and ebuild revisions.

    ``package_name`` lets the parser recognise an optional upstream series after
    a package prefix, for example ``flutter-engine-3.47-gcc-climits-r1.patch``.
    A legacy name without ``-rN`` is accepted only to support a deliberate
    one-time migration; generated ebuilds always use :meth:`canonical_filename`.

    Legacy filenames with dot-separated version sequences (such as
    ``dart-3.13.3-fix.patch``) are conservatively parsed with the version
    number treated as a series qualifier. This preserves the exact identity
    into ``dart-3.13.3-fix-r1.patch`` without guessing whether the number was a
    full package version (PV) or an intentional branch series qualifier.
    Maintainers migrate canonical patches by deliberately renaming them to
    unversioned family names (e.g. ``dart-fix-r1.patch``) when stripping is desired.
    """

    name = Path(filename).name
    if name != filename:
        raise ValueError(f"Patch filename must not contain a directory: {filename}")
    match = _PATCH_FILENAME_RE.fullmatch(name)
    if not match:
        raise ValueError(f"Malformed patch filename: {filename}")

    stem = match.group("stem")
    if not stem or stem.startswith("-") or stem.endswith("-r") or re.search(r"-r0$", stem):
        raise ValueError(f"Malformed patch filename: {filename}")

    series = None
    family = stem
    if package_name and stem.startswith(f"{package_name}-"):
        local_stem = stem.removeprefix(f"{package_name}-")
        series_match = _SERIES_RE.fullmatch(local_stem)
        if series_match:
            series = series_match.group("series")
            family = f"{package_name}-{series_match.group('family')}"

    return PatchFilename(
        name,
        family,
        series,
        int(match.group("revision")) if match.group("revision") else None,
        package_name,
    )


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


_PATCHES_ARRAY_OPEN_RE = re.compile(
    r"^\s*PATCHES\s*(?P<op>\+?=)\s*\((?P<rest>.*)$"
)
_PATCHES_ASSIGN_RE = re.compile(r"^\s*PATCHES\s*\+?=")
_DIRECT_PATCH_COMMAND_RE = re.compile(r"\b(?:eapply|epatch)\s+")


def _check_patch_content(content: str, ebuild: Path, line_num: int) -> None:
    """Validate that patch references inside PATCHES use ${FILESDIR}."""

    if ".patch" in content:
        for token in re.findall(r'[^\s"\'()]+\.patch', content):
            if not token.startswith("${FILESDIR}/"):
                raise ValueError(
                    f"PATCHES entry in {ebuild.name}:{line_num} does not reference "
                    f"${{FILESDIR}}: {token}"
                )


def _patch_references(ebuild: Path) -> list[str]:
    """Return FILESDIR patch references from the ebuild's PATCHES array only.

    Fails closed on unsupported patch-bearing syntax (e.g. scalar PATCHES,
    direct eapply/epatch commands, non-FILESDIR patches, or unhandled
    ${FILESDIR}/*.patch references) to ensure valid-but-different patch
    declarations cannot silently result in zero inherited patches.
    """

    references: list[str] = []
    in_patches = False
    lines = ebuild.read_text().splitlines()

    for line_num, line in enumerate(lines, 1):
        clean_line = line.strip()
        if clean_line.startswith("#"):
            continue

        code_part, _, _ = line.partition("#")

        if not in_patches:
            opening = _PATCHES_ARRAY_OPEN_RE.match(code_part)
            if opening:
                rest = opening.group("rest")
                if ")" in rest:
                    content, _, _ = rest.partition(")")
                    _check_patch_content(content, ebuild, line_num)
                    references.extend(_FILESDIR_REF_RE.findall(content))
                else:
                    _check_patch_content(rest, ebuild, line_num)
                    references.extend(_FILESDIR_REF_RE.findall(rest))
                    in_patches = True
                continue

            if _PATCHES_ASSIGN_RE.match(code_part):
                raise ValueError(
                    f"Unsupported scalar PATCHES syntax in {ebuild.name}:{line_num}: {clean_line}"
                )
            if _DIRECT_PATCH_COMMAND_RE.search(code_part):
                raise ValueError(
                    f"Unsupported direct patch command in {ebuild.name}:{line_num}: {clean_line}"
                )
            continue

        if ")" in code_part:
            content, _, _ = code_part.partition(")")
            _check_patch_content(content, ebuild, line_num)
            references.extend(_FILESDIR_REF_RE.findall(content))
            in_patches = False
        else:
            _check_patch_content(code_part, ebuild, line_num)
            references.extend(_FILESDIR_REF_RE.findall(code_part))

    if in_patches:
        raise ValueError(f"Unclosed PATCHES array in {ebuild.name}")

    all_filesdir_refs: list[str] = []
    for line in lines:
        if line.strip().startswith("#"):
            continue
        code, _, _ = line.partition("#")
        all_filesdir_refs.extend(_FILESDIR_REF_RE.findall(code))

    unhandled_patches = [
        ref
        for ref in all_filesdir_refs
        if ref.endswith(".patch") and ref not in references
    ]
    if unhandled_patches:
        detail = ", ".join(unhandled_patches)
        raise ValueError(
            f"Ebuild {ebuild.name} contains patch reference(s) outside supported "
            f"PATCHES array: {detail}"
        )

    seen: set[str] = set()
    deduped: list[str] = []
    for ref in references:
        if ref not in seen:
            seen.add(ref)
            deduped.append(ref)
    return deduped


def inherit_previous_patch_files(
    previous_ebuild: Path,
    new_ebuild: Path,
    source_root: Path,
    work_root: Path,
    package: str,
) -> list[str]:
    """Keep the previous ebuild's exact patch identities in a new ebuild.

    Patch selection is intentionally ancestry-based: a newer ``-rN`` file in
    ``files/`` is never discovered or attached automatically.  A legacy name
    is copied once to its canonical ``-r1`` migration name, while a canonical
    patch is reused byte-for-byte.  The copy into an isolated dry-run tree is
    solely to make that temporary tree self-contained; no version-qualified
    duplicate is created.
    """

    package_name = package.rsplit("/", 1)[-1]
    prefix = f"{package_name}-"
    if not previous_ebuild.stem.startswith(prefix):
        raise ValueError(f"{previous_ebuild.name} does not belong to package {package}")

    old_pvr = previous_ebuild.stem.removeprefix(prefix)
    old_values = _values(package_name, old_pvr)
    replacements: dict[str, str] = {}
    inherited: list[str] = []

    for reference in _patch_references(previous_ebuild):
        source_name = _expand(reference, old_values)
        parsed = parse_patch_filename(source_name, package_name)
        destination_name = parsed.canonical_filename()
        source = source_root / package / "files" / source_name
        destination = work_root / package / "files" / destination_name
        if not source.is_file():
            raise FileNotFoundError(
                f"Patch referenced by {previous_ebuild.name} is missing: {source}"
            )

        # In a real update, canonical patches already live in the shared
        # FILESDIR.  Dry-runs copy that one exact file into their isolated tree.
        if source_root.resolve() != work_root.resolve() or source_name != destination_name:
            destination.parent.mkdir(parents=True, exist_ok=True)
            if destination.exists() and destination.read_bytes() != source.read_bytes():
                raise FileExistsError(
                    f"Refusing to overwrite differing inherited patch: {destination}"
                )
            if not destination.exists():
                shutil.copy2(source, destination)

        replacements[reference] = destination_name
        inherited.append(f"{package}/files/{destination_name}")

    text = new_ebuild.read_text()
    for reference, destination_name in replacements.items():
        text = text.replace(
            f"${{FILESDIR}}/{reference}", f"${{FILESDIR}}/{destination_name}"
        )
    new_ebuild.write_text(text)
    return inherited


def refresh_inherited_patch_reference(
    new_ebuild: Path, previous_filename: str, refreshed_filename: str
) -> None:
    """Deliberately move one new ebuild from an inherited patch to ``-rN``.

    This is an explicit maintainer action after source CI has shown that a
    patch needs refreshing.  It never alters the previous ebuild or either
    patch file, and it refuses a change across logical patch families.
    """

    previous = parse_patch_filename(previous_filename)
    refreshed = parse_patch_filename(refreshed_filename)
    if (previous.family, previous.series) != (refreshed.family, refreshed.series):
        raise ValueError("Refreshed patch must remain in the same patch family")
    if previous.revision is None or refreshed.revision is None:
        raise ValueError("Refreshed patches must use immutable -rN filenames")
    if refreshed.revision <= previous.revision:
        raise ValueError("Refreshed patch revision must increase")

    text = new_ebuild.read_text()
    old_reference = f"${{FILESDIR}}/{previous_filename}"
    if old_reference not in text:
        raise ValueError(f"New ebuild does not reference {previous_filename}")
    new_ebuild.write_text(text.replace(old_reference, f"${{FILESDIR}}/{refreshed_filename}"))


def drop_inherited_patch_reference(new_ebuild: Path, filename: str) -> None:
    """Remove an upstreamed patch from a new ebuild without deleting its file."""

    parse_patch_filename(filename)
    lines = new_ebuild.read_text().splitlines(keepends=True)
    reference = f"${{FILESDIR}}/{filename}"
    kept = [line for line in lines if reference not in line]
    if len(kept) == len(lines):
        raise ValueError(f"New ebuild does not reference {filename}")
    new_ebuild.write_text("".join(kept))


def carry_forward_versioned_files(
    previous_ebuild: Path,
    new_version: str,
    source_root: Path,
    work_root: Path,
    package: str,
) -> list[str]:
    """Copy version-qualified non-patch FILESDIR assets referenced by an ebuild.

    Patches are handled separately by :func:`inherit_previous_patch_files` so
    their immutable patch revision does not track the package version.  Only
    non-patch references containing PV/P/PVR/PF are copied. Unversioned shared
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
        if reference.endswith(".patch") or not any(
            token in reference for token in _VERSIONED_TOKENS
        ):
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
