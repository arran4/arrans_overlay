"""Regression for Dart/Flutter packaging before and after daily deduplication."""
import shutil
import tempfile
import unittest
from pathlib import Path

from maintain_virtuals import (
    prepare, cleanup, available_providers, all_versions,
    matching_ebuilds, virtual_content,
)
from prune_dedup_manifests import prune_package
from verify_manifest import extract_uris, parse_ebuild_variables

ROOT = Path(__file__).parents[1]


class ScheduledDedupeIntegrationTest(unittest.TestCase):
    def test_real_packages_survive_dedupe_with_usable_virtuals_and_manifests(self):
        packages = (
            "dev-lang/dart", "dev-lang/dart-bin",
            "dev-lang/flutter", "dev-lang/flutter-bin",
            "dev-libs/flutter-engine",
            "virtual/dart", "virtual/flutter",
        )
        with tempfile.TemporaryDirectory() as tmp:
            sandbox = Path(tmp)
            for package in packages:
                shutil.copytree(ROOT / package, sandbox / package)

            prepare(sandbox)
            removed_packages = set()
            old_versions = {
                "dev-lang/dart": ("3.13.3-r3", "3.13.5"),
                "dev-lang/dart-bin": ("3.13.3-r2", "3.13.4", "3.13.5", "3.13.6"),
                "dev-lang/flutter-bin": (
                    "3.47.2-r1", "3.47.3-r1", "3.47.4-r1", "3.47.5-r1",
                    "3.47.6", "3.47.7", "3.47.8",
                ),
                "dev-lang/flutter": ("3.47.2-r1",),
                "dev-libs/flutter-engine": ("3.47.2-r1",),
            }
            for package, versions in old_versions.items():
                dirname = package.rsplit("/", 1)[-1]
                for version in versions:
                    old = sandbox / package / f"{dirname}-{version}.ebuild"
                    # Versions in the historical #975 cleanup are optional:
                    # the next checkout may already contain the cleaned state.
                    old.unlink(missing_ok=True)
                removed_packages.add(package)

            cleanup(sandbox)
            # Check the complete provider/virtual contract in both a pre-
            # deduped and an already-deduped working tree, without relying on
            # a retired historical Flutter or Dart version.
            for package in ("dart", "flutter"):
                versions = all_versions(sandbox, package)
                self.assertTrue(versions, package)
                virtual_directory = sandbox / "virtual" / package
                virtual_files = list(virtual_directory.glob("*.ebuild"))
                self.assertEqual(len(virtual_files), len(versions), package)
                for version in versions:
                    self.assertTrue(
                        available_providers(sandbox, package, version),
                        f"{package}-{version}",
                    )
                    matched = matching_ebuilds(
                        sandbox, f"virtual/{package}", version
                    )
                    self.assertEqual(len(matched), 1, f"{package}-{version}")
                    self.assertEqual(
                        matched[0].read_text(),
                        virtual_content(sandbox, package, version),
                    )

            self.assertFalse(matching_ebuilds(
                sandbox, "virtual/dart", "3.13.3"
            ))
            # Both Flutter 3.47.2 providers are removed by this simulation.
            # A virtual with no remaining exact-version provider must retire.
            self.assertFalse(matching_ebuilds(
                sandbox, "virtual/flutter", "3.47.2"
            ))

            for package in removed_packages:
                directory = sandbox / package
                # An already-cleaned Manifest is a valid starting fixture.
                prune_package(directory)
                recorded = {
                    line.split()[1] for line in (directory / "Manifest").read_text().splitlines()
                    if line.startswith("DIST ")
                }
                referenced = set()
                for path in directory.glob("*.ebuild"):
                    content = path.read_text()
                    variables = parse_ebuild_variables(path.name, content)
                    referenced.update(name for _, name in extract_uris(content, variables))
                self.assertEqual(recorded, referenced, package)
                self.assertFalse(prune_package(directory), f"non-idempotent {package}")


if __name__ == "__main__":
    unittest.main()
