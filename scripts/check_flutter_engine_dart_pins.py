#!/usr/bin/env python3
"""Check selected Flutter Engine DEPS pins without building or publishing an SDK.

This is a release-provenance and generator regression check, not an assertion
that unrelated upstream DEPS exclusion changes have been reviewed.
"""
from __future__ import annotations

import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import urllib.request

import generate_flutter_engine_ebuild as generator

RELEASES_URL = (
    "https://storage.googleapis.com/flutter_infra_release/releases/"
    "releases_linux.json"
)
FLUTTER_RAW = "https://raw.githubusercontent.com/flutter/flutter"
BASE_ENGINE_REVISION = "a804b261645ef8c13eb3d5c44a5c2fb0340c5539"
BASE_DART_REVISION = "60a57cd42d64dc03e9f07aa60a2e250755c1ef28"
# Known regression case, not a substitute for checking upstream release data.
KNOWN_RELEASE_PINS = {
    "3.47.7": "04bcd1036cdc799ac6564988f159ee454d42c822",
    "3.47.8": "416e33b0ffaef062a60ec966bb8c82ed2b83f128",
}
DART_PREBUILTS = (
    "engine/src/flutter/prebuilts/linux-arm64/dart-sdk",
    "engine/src/flutter/prebuilts/linux-x64/dart-sdk",
)
SHA = re.compile(r"[0-9a-f]{40}\Z")


def read_url(url: str) -> str:
    with urllib.request.urlopen(url, timeout=45) as response:
        return response.read().decode("utf-8")


def checked_sha(value: str, label: str) -> str:
    if not SHA.fullmatch(value):
        raise ValueError(f"invalid {label}: {value!r}")
    return value


def stable_release(version: str) -> str:
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise ValueError(f"invalid stable Flutter version {version!r}")
    metadata = json.loads(read_url(RELEASES_URL))
    matches = [
        release for release in metadata.get("releases", [])
        if release.get("version") == version
        and release.get("channel") == "stable"
    ]
    if len(matches) != 1:
        raise ValueError(
            f"expected exactly one authoritative stable release {version}; "
            f"got {len(matches)}"
        )
    return checked_sha(matches[0]["hash"], "Flutter release hash")


def require_revision(namespace: dict, expected: str, origin: str) -> None:
    variables = namespace["vars"]
    actual = variables.get("dart_revision")
    if actual != expected:
        raise ValueError(
            f"{origin} Dart pin differs from authoritative expectation: "
            f"expected {expected}, got {actual!r}"
        )


def validate_target_prebuilts(deps_path: Path, dart_revision: str) -> None:
    namespace = generator.load_deps(deps_path)
    require_revision(namespace, dart_revision, str(deps_path))
    active = dict(generator.active_dependencies(namespace))
    reviews = generator.reviewed_exclusions_for_dart_revision(dart_revision)

    for destination in DART_PREBUILTS:
        if destination not in active:
            raise ValueError(f"target Dart SDK prebuilt missing: {destination}")
        dependency = active[destination]
        generator.validate_reviewed_exclusion(destination, dependency, reviews)
        identity = generator.dependency_identity(destination, dependency)
        assert len(identity.packages) == 1
        if identity.packages[0][1] != f"git_revision:{dart_revision}":
            raise ValueError(f"wrong Dart prebuilt pin: {destination}")

        for wrong in (
            {"package": "unreviewed/dart-sdk"},
            {"version": "git_revision:" + "0" * 40},
            {"condition": "changed_condition"},
        ):
            tampered = dict(dependency)
            if "condition" in wrong:
                tampered["condition"] = wrong["condition"]
            else:
                package = dict(dependency["packages"][0])
                package.update(wrong)
                tampered["packages"] = [package]
            try:
                generator.validate_reviewed_exclusion(
                    destination, tampered, reviews
                )
            except ValueError as exc:
                if "DEPS exclusion changed" not in str(exc):
                    raise
            else:
                raise ValueError(
                    f"tampered Dart prebuilt incorrectly accepted: {destination}"
                )


def ebuild_assignment(text: str, name: str) -> str:
    match = re.search(rf'^{re.escape(name)}="([^"]+)"$', text, re.MULTILINE)
    if not match:
        raise ValueError(f"missing {name} assignment")
    return match.group(1)


def validate_generated_ebuilds(
    flutter_ebuild: Path,
    version: str,
    framework_revision: str,
    engine_revision: str,
    dart_revision: str,
    dart_sdk_version: str,
) -> None:
    """Check generated fields that are intentionally outside DEPS/pub blocks."""
    flutter_text = flutter_ebuild.read_text()
    if ebuild_assignment(flutter_text, "FLUTTER_GIT_COMMIT") != framework_revision:
        raise ValueError("Flutter ebuild has a stale framework revision")
    if ebuild_assignment(flutter_text, "FLUTTER_ENGINE_REV") != engine_revision:
        raise ValueError("Flutter ebuild has a stale Engine revision")
    if ebuild_assignment(
        flutter_text, "FLUTTER_DART_SDK_VERSION",
    ) != dart_sdk_version:
        raise ValueError("Flutter ebuild has a stale Dart SDK version")
    if f"\t~dev-libs/flutter-engine-{version}" not in flutter_text:
        raise ValueError("Flutter ebuild has a stale Flutter Engine dependency")
    if '"dartSdkVersion": "${FLUTTER_DART_SDK_VERSION}"' not in flutter_text:
        raise ValueError("Flutter ebuild does not use the generated Dart SDK version")

    engine_ebuild = (
        flutter_ebuild.parents[2] / "dev-libs" / "flutter-engine"
        / f"flutter-engine-{version}.ebuild"
    )
    if not engine_ebuild.exists():
        raise ValueError(f"missing matching Flutter Engine ebuild: {engine_ebuild}")
    engine_text = engine_ebuild.read_text()
    if ebuild_assignment(engine_text, "FLUTTER_ENGINE_REV") != engine_revision:
        raise ValueError("Flutter Engine ebuild has a stale Engine revision")
    if f'SDK_REV="{dart_revision}"' not in engine_text:
        raise ValueError("Flutter Engine ebuild has a stale Dart source revision")


@contextmanager
def selected_generator_pin(pin: str):
    original = generator.DART_REVISION
    generator.DART_REVISION = pin
    try:
        yield
    finally:
        generator.DART_REVISION = original


def check_sequential_renders(baseline_path: Path, target_pin: str) -> None:
    """Render old -> new -> old in the same interpreter, checking isolation.

    Change only the Dart variable in an otherwise known-reviewed baseline
    DEPS graph, so the check isolates pin handling from other release changes.
    """
    baseline_text = baseline_path.read_text()
    old_declaration = f"'dart_revision': '{BASE_DART_REVISION}'"
    if baseline_text.count(old_declaration) != 1:
        raise ValueError("baseline DEPS has an unexpected Dart declaration")

    with tempfile.TemporaryDirectory(prefix="engine-dart-pin-sequence-") as tmp:
        target_fixture = Path(tmp) / "modified.DEPS"
        target_fixture.write_text(
            baseline_text.replace(
                old_declaration, f"'dart_revision': '{target_pin}'", 1
            )
        )
        original_exclusions = generator.REVIEWED_EXCLUSIONS.copy()
        with selected_generator_pin(BASE_DART_REVISION):
            baseline_result = generator.render(baseline_path)

        with selected_generator_pin(target_pin):
            validate_target_prebuilts(target_fixture, target_pin)
            target_result = generator.render(target_fixture)
            # The generated source graph may contain revision references;
            # it need not be identical to the baseline rendered graph.
            if target_pin != BASE_DART_REVISION and (
                target_result == baseline_result
            ):
                raise ValueError(
                    "changing the Dart revision had no effect on render"
                )

        with selected_generator_pin(BASE_DART_REVISION):
            if generator.render(baseline_path) != baseline_result:
                raise ValueError("cross-release generator state contamination")
        if generator.REVIEWED_EXCLUSIONS != original_exclusions:
            raise ValueError("reviewed exclusions mutated across renders")


def report(message: str) -> None:
    print(message, flush=True)
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as summary:
            summary.write(message + "\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--version", help="Upstream Flutter stable version"
    )
    parser.add_argument(
        "--ebuild", type=Path,
        help="Flutter ebuild whose release version and generated identities to audit",
    )
    parser.add_argument(
        "--expected-dart-revision",
        help="Optional additional reviewed pin check"
    )
    parser.add_argument(
        "--full-render", action="store_true",
        help="Fail if the complete selected Engine DEPS graph cannot render"
    )
    args = parser.parse_args()
    try:
        version = args.version
        if args.ebuild:
            match = re.fullmatch(r"flutter-(\d+\.\d+\.\d+)\.ebuild",
                                 args.ebuild.name)
            if not match:
                raise ValueError(f"invalid Flutter ebuild name: {args.ebuild}")
            ebuild_version = match.group(1)
            if version and version != ebuild_version:
                raise ValueError("--version disagrees with --ebuild")
            version = ebuild_version
        if not version:
            raise ValueError("provide --version or --ebuild")
        release_ref = stable_release(version)
        base_text = read_url(
            f"{FLUTTER_RAW}/{BASE_ENGINE_REVISION}/DEPS"
        )
        target_engine_ref = checked_sha(
            read_url(
                f"{FLUTTER_RAW}/{release_ref}/bin/internal/engine.version"
            ).strip(),
            "Flutter Engine revision",
        )
        flutter_deps_text = read_url(f"{FLUTTER_RAW}/{release_ref}/DEPS")
        engine_deps_text = read_url(
            f"{FLUTTER_RAW}/{target_engine_ref}/DEPS"
        )

        with tempfile.TemporaryDirectory(prefix="flutter-engine-pin-audit-") as tmp:
            paths = {
                "baseline": Path(tmp) / "baseline.DEPS",
                "flutter": Path(tmp) / "flutter.DEPS",
                "engine": Path(tmp) / "engine.DEPS",
            }
            for label, content in (
                ("baseline", base_text),
                ("flutter", flutter_deps_text),
                ("engine", engine_deps_text),
            ):
                paths[label].write_text(content)

            flutter_namespace = generator.load_deps(paths["flutter"])
            dart_pin = checked_sha(
                flutter_namespace["vars"]["dart_revision"], "Flutter Dart pin"
            )
            require_revision(
                generator.load_deps(paths["engine"]),
                dart_pin, "Flutter Engine"
            )
            known = KNOWN_RELEASE_PINS.get(version)
            if known and dart_pin != known:
                raise ValueError(
                    f"regression release {version} Dart pin changed "
                    f"from {known} to {dart_pin}"
                )
            if args.expected_dart_revision and (
                dart_pin != checked_sha(
                    args.expected_dart_revision, "expected Dart pin"
                )
            ):
                raise ValueError(
                    "authoritative Flutter Dart pin differs from "
                    "the expected Dart revision"
                )

            validate_target_prebuilts(paths["engine"], dart_pin)
            check_sequential_renders(paths["baseline"], dart_pin)
            if args.ebuild:
                metadata = json.loads(read_url(RELEASES_URL))
                release = next(
                    item for item in metadata["releases"]
                    if item.get("version") == version
                    and item.get("channel") == "stable"
                    and item.get("hash") == release_ref
                )
                validate_generated_ebuilds(
                    args.ebuild, version, release_ref, target_engine_ref,
                    dart_pin, str(release["dart_sdk_version"]),
                )
            report(
                f"PASS: Flutter {version} (release {release_ref}, "
                f"Engine {target_engine_ref}) pins Dart {dart_pin}; "
                "both real upstream prebuilt exclusions match. "
                "Old/new/old rendering is isolated and fail-closed."
            )
            if args.full_render:
                with selected_generator_pin(dart_pin):
                    # Failing here is intentional when unrelated DEPS
                    # identities changed without independent review.
                    rendered = generator.render(paths["engine"])
                    if "# BEGIN GENERATED FLUTTER ENGINE DEPS" not in rendered:
                        raise ValueError("no generated Engine DEPS block")
                report(
                    "PASS: the complete selected upstream Engine DEPS "
                    "graph rendered without unreviewed exclusions."
                )
            else:
                report(
                    "Full selected-release rendering NOT certified: "
                    "run the optional strict full-render audit."
                )
        return 0
    except (ValueError, KeyError, AssertionError, OSError) as exc:
        report(f"FAIL: {exc}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
