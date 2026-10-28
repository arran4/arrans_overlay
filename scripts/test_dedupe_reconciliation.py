"""Regression for Dart/Flutter packaging before and after daily deduplication."""
import shutil
import tempfile
import unittest
from pathlib import Path

from maintain_virtuals import prepare, cleanup, available_providers, all_versions
from prune_dedup_manifests import prune_package
from verify_manifest import extract_uris, parse_ebuild_variables

ROOT = Path(__file__).parents[1]


class ScheduledDedupeIntegrationTest(unittest.TestCase):
    def test_real_packages_survive_dedupe_with_usable_virtuals_and_manifests(self):
        packages = (
            "dev-lang/dart", "dev-lang/dart-bin",
            "dev-lang/flutter", "dev-lang/flutter-bin",
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
                    "3.47.2-r1", "3.47.3-r1", "3.47.4-r1", "3.47.5-r1", "3.47.6",
                ),
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
            newest_dart = all_versions(sandbox, "dart")[-1]
            self.assertTrue(available_providers(sandbox, "dart", newest_dart))
            # Reconcile every version actually present in the checkout.
            # A successful daily dedupe may already have removed 3.47.7.
            for version in all_versions(sandbox, "flutter"):
                self.assertTrue(available_providers(sandbox, "flutter", version))
                self.assertTrue(list(
                    (sandbox / "virtual/flutter").glob(f"flutter-{version}*.ebuild")
                ))
            newest_flutter = all_versions(sandbox, "flutter")[-1]
            self.assertTrue(available_providers(sandbox, "flutter", newest_flutter))
            self.assertFalse((sandbox / "virtual/dart/dart-3.13.3-r1.ebuild").exists())
            old_flutter = list((sandbox / "virtual/flutter").glob("flutter-3.47.2*.ebuild"))
            self.assertEqual(len(old_flutter), 1)
            self.assertIn("~dev-lang/flutter-3.47.2", old_flutter[0].read_text())
            self.assertNotIn("~dev-lang/flutter-bin-3.47.2", old_flutter[0].read_text())
            self.assertTrue(list((sandbox / "virtual/dart").glob(f"dart-{newest_dart}*.ebuild")))
            self.assertTrue(list((sandbox / "virtual/flutter").glob(f"flutter-{newest_flutter}*.ebuild")))

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
