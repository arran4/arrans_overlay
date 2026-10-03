import tempfile
import unittest
from pathlib import Path

from source_update_utils import (
    carry_forward_versioned_files,
    drop_inherited_patch_reference,
    inherit_previous_patch_files,
    parse_patch_filename,
    refresh_inherited_patch_reference,
)


class SourceUpdateUtilsTest(unittest.TestCase):
    def make_package(self, root: Path, package: str, ebuild_name: str, body: str) -> Path:
        package_dir = root / package
        (package_dir / "files").mkdir(parents=True)
        ebuild = package_dir / ebuild_name
        ebuild.write_text(body)
        return ebuild

    def test_carries_only_referenced_versioned_non_patch_assets(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source = Path(source_td)
            work = Path(work_td)
            previous = self.make_package(
                source,
                "dev-lang/dart",
                "dart-3.13.3-r2.ebuild",
                'PATCHES=(\n'
                '  "${FILESDIR}/dart-fix-r1.patch"\n'
                '  "${FILESDIR}/shared.patch"\n'
                ')\n',
            )
            files = source / "dev-lang/dart/files"
            (files / "dart-fix-r1.patch").write_text("patch\n")
            (files / "shared.patch").write_text("shared\n")

            carried = carry_forward_versioned_files(
                previous, "3.14.0", source, work, "dev-lang/dart"
            )

            self.assertFalse((work / "dev-lang/dart/files/dart-fix-r1.patch").exists())
            self.assertFalse((work / "dev-lang/dart/files/shared.patch").exists())
            self.assertEqual(
                carried,
                [],
            )

    def test_carries_pv_helpers_and_pf_revision_references(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source = Path(source_td)
            work = Path(work_td)
            previous = self.make_package(
                source,
                "dev-libs/flutter-engine",
                "flutter-engine-3.47.2-r1.ebuild",
                'PATCHES=( "${FILESDIR}/flutter-engine-fix-r1.patch" )\n'
                'HELPER="${FILESDIR}/${PF}-helper.py"\n',
            )
            files = source / "dev-libs/flutter-engine/files"
            (files / "flutter-engine-fix-r1.patch").write_text("patch\n")
            (files / "flutter-engine-3.47.2-r1-helper.py").write_text("helper\n")

            carried = carry_forward_versioned_files(
                previous, "3.48.0", source, work, "dev-libs/flutter-engine"
            )

            self.assertFalse((work / "dev-libs/flutter-engine/files/flutter-engine-fix-r1.patch").exists())
            self.assertEqual(
                (work / "dev-libs/flutter-engine/files/flutter-engine-3.48.0-helper.py").read_text(),
                "helper\n",
            )
            self.assertEqual(len(carried), 1)

    def test_missing_referenced_asset_fails_closed(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source = Path(source_td)
            work = Path(work_td)
            previous = self.make_package(
                source,
                "dev-lang/dart",
                "dart-3.13.3.ebuild",
                'HELPER="${FILESDIR}/${P}-missing.py"\n',
            )

            with self.assertRaises(FileNotFoundError):
                carry_forward_versioned_files(
                    previous, "3.14.0", source, work, "dev-lang/dart"
                )

    def test_differing_existing_destination_fails_closed(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source = Path(source_td)
            work = Path(work_td)
            previous = self.make_package(
                source,
                "dev-lang/dart",
                "dart-3.13.3.ebuild",
                'HELPER="${FILESDIR}/${P}-fix.py"\n',
            )
            source_file = source / "dev-lang/dart/files/dart-3.13.3-fix.py"
            source_file.write_text("old\n")
            destination = work / "dev-lang/dart/files/dart-3.14.0-fix.py"
            destination.parent.mkdir(parents=True)
            destination.write_text("different\n")

            with self.assertRaises(FileExistsError):
                carry_forward_versioned_files(
                    previous, "3.14.0", source, work, "dev-lang/dart"
                )

    def test_parses_immutable_patch_names_and_optional_series(self):
        plain = parse_patch_filename("foo-r1.patch")
        self.assertEqual((plain.family, plain.series, plain.revision), ("foo", None, 1))
        self.assertEqual(parse_patch_filename("foo-r12.patch").revision, 12)
        package = parse_patch_filename("dart-binaryen-assert-unused-r1.patch", "dart")
        self.assertEqual(package.family, "dart-binaryen-assert-unused")
        series = parse_patch_filename(
            "flutter-engine-3.47-gcc-climits-r2.patch", "flutter-engine"
        )
        self.assertEqual(
            (series.family, series.series, series.revision, series.canonical_filename()),
            ("flutter-engine-gcc-climits", "3.47", 2, "flutter-engine-3.47-gcc-climits-r2.patch"),
        )

    def test_rejects_malformed_names_and_accepts_legacy_for_migration(self):
        for name in ("foo.patch.bak", "foo-r0.patch", "foo-r.patch", "-r1.patch"):
            with self.subTest(name=name):
                with self.assertRaises(ValueError):
                    parse_patch_filename(name)
        legacy = parse_patch_filename("dart-3.13.3-fix.patch", "dart")
        self.assertTrue(legacy.is_legacy)
        self.assertEqual(legacy.canonical_filename(), "dart-3.13.3-fix-r1.patch")

    def test_inherits_exact_previous_patch_family_without_scanning_files(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source, work = Path(source_td), Path(work_td)
            previous = self.make_package(
                source,
                "dev-lang/dart",
                "dart-3.13.3-r6.ebuild",
                'PATCHES=(\n  "${FILESDIR}/dart-foo-r1.patch"\n)\n',
            )
            new = work / "dev-lang/dart/dart-99.0.0.ebuild"
            new.parent.mkdir(parents=True)
            new.write_text(previous.read_text())
            files = source / "dev-lang/dart/files"
            (files / "dart-foo-r1.patch").write_text("old patch\n")
            (files / "dart-foo-r2.patch").write_text("unrelated refresh\n")
            (files / "dart-unrelated-r9.patch").write_text("unrelated family\n")

            inherited = inherit_previous_patch_files(
                previous, new, source, work, "dev-lang/dart"
            )

            self.assertEqual(inherited, ["dev-lang/dart/files/dart-foo-r1.patch"])
            self.assertIn('"${FILESDIR}/dart-foo-r1.patch"', new.read_text())
            self.assertNotIn("dart-foo-r2.patch", new.read_text())
            self.assertEqual(
                (work / "dev-lang/dart/files/dart-foo-r1.patch").read_text(),
                "old patch\n",
            )
            self.assertFalse((work / "dev-lang/dart/files/dart-foo-r2.patch").exists())
            self.assertEqual((files / "dart-foo-r1.patch").read_text(), "old patch\n")

    def test_migrates_legacy_patch_once_and_keeps_old_ebuild_unchanged(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source, work = Path(source_td), Path(work_td)
            previous = self.make_package(
                source,
                "dev-lang/dart",
                "dart-3.13.3-r6.ebuild",
                'PATCHES=( "${FILESDIR}/${P}-fix.patch" )\n',
            )
            (source / "dev-lang/dart/files/dart-3.13.3-fix.patch").write_text("legacy\n")
            new = work / "dev-lang/dart/dart-99.0.0.ebuild"
            new.parent.mkdir(parents=True)
            new.write_text(previous.read_text())

            inherited = inherit_previous_patch_files(
                previous, new, source, work, "dev-lang/dart"
            )

            self.assertEqual(inherited, ["dev-lang/dart/files/dart-3.13.3-fix-r1.patch"])
            self.assertIn("dart-3.13.3-fix-r1.patch", new.read_text())
            self.assertIn("${P}-fix.patch", previous.read_text())
            self.assertEqual(
                (work / "dev-lang/dart/files/dart-3.13.3-fix-r1.patch").read_text(),
                "legacy\n",
            )

    def test_refresh_and_drop_change_only_the_new_ebuild(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            old = root / "dart-3.13.3.ebuild"
            new = root / "dart-99.0.0.ebuild"
            old.write_text('PATCHES=( "${FILESDIR}/dart-foo-r1.patch" )\n')
            new.write_text(old.read_text())

            refresh_inherited_patch_reference(new, "dart-foo-r1.patch", "dart-foo-r2.patch")
            self.assertIn("dart-foo-r2.patch", new.read_text())
            self.assertIn("dart-foo-r1.patch", old.read_text())
            with self.assertRaises(ValueError):
                refresh_inherited_patch_reference(
                    new, "dart-foo-r2.patch", "dart-other-r3.patch"
                )

            drop_inherited_patch_reference(new, "dart-foo-r2.patch")
            self.assertNotIn("dart-foo-r2.patch", new.read_text())
            self.assertIn("dart-foo-r1.patch", old.read_text())

    def test_real_future_version_reuses_patches_and_copies_only_engine_helper(self):
        repo = Path(__file__).parents[1]
        with tempfile.TemporaryDirectory() as td:
            work = Path(td)
            dart_old = repo / "dev-lang/dart/dart-3.13.3-r3.ebuild"
            dart_new = work / "dev-lang/dart/dart-99.0.0.ebuild"
            dart_new.parent.mkdir(parents=True)
            dart_new.write_text(dart_old.read_text())
            inherited = inherit_previous_patch_files(
                dart_old, dart_new, repo, work, "dev-lang/dart"
            )
            self.assertEqual(len(inherited), 3)
            self.assertNotIn("99.0.0", dart_new.read_text())
            self.assertFalse(
                (repo / "dev-lang/dart/files/dart-99.0.0-binaryen-assert-unused.patch").exists()
            )

            engine_old = repo / "dev-libs/flutter-engine/flutter-engine-3.47.2-r1.ebuild"
            engine_new = work / "dev-libs/flutter-engine/flutter-engine-99.0.0.ebuild"
            engine_new.parent.mkdir(parents=True)
            engine_new.write_text(engine_old.read_text())
            engine_patches = inherit_previous_patch_files(
                engine_old, engine_new, repo, work, "dev-libs/flutter-engine"
            )
            carried = carry_forward_versioned_files(
                engine_old, "99.0.0", repo, work, "dev-libs/flutter-engine"
            )
            self.assertEqual(len(engine_patches), 24)
            self.assertEqual(
                carried,
                ["dev-libs/flutter-engine/files/flutter-engine-99.0.0-package-config.py"],
            )
            self.assertFalse(
                (repo / "dev-libs/flutter-engine/files/flutter-engine-99.0.0-gcc-climits.patch").exists()
            )


if __name__ == "__main__":
    unittest.main()
