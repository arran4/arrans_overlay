import tempfile
import unittest
from pathlib import Path

from source_update_utils import carry_forward_versioned_files


class SourceUpdateUtilsTest(unittest.TestCase):
    def make_package(self, root: Path, package: str, ebuild_name: str, body: str) -> Path:
        package_dir = root / package
        (package_dir / "files").mkdir(parents=True)
        ebuild = package_dir / ebuild_name
        ebuild.write_text(body)
        return ebuild

    def test_carries_only_referenced_versioned_assets(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source = Path(source_td)
            work = Path(work_td)
            previous = self.make_package(
                source,
                "dev-lang/dart",
                "dart-3.13.3-r2.ebuild",
                'PATCHES=(\n'
                '  "${FILESDIR}/${P}-fix.patch"\n'
                '  "${FILESDIR}/shared.patch"\n'
                ')\n',
            )
            files = source / "dev-lang/dart/files"
            (files / "dart-3.13.3-fix.patch").write_text("patch\n")
            (files / "shared.patch").write_text("shared\n")

            carried = carry_forward_versioned_files(
                previous, "3.14.0", source, work, "dev-lang/dart"
            )

            target = work / "dev-lang/dart/files/dart-3.14.0-fix.patch"
            self.assertEqual(target.read_text(), "patch\n")
            self.assertFalse((work / "dev-lang/dart/files/shared.patch").exists())
            self.assertEqual(
                carried,
                ["dev-lang/dart/files/dart-3.14.0-fix.patch"],
            )

    def test_carries_pv_helpers_and_pf_revision_references(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source = Path(source_td)
            work = Path(work_td)
            previous = self.make_package(
                source,
                "dev-libs/flutter-engine",
                "flutter-engine-3.47.2-r1.ebuild",
                'PATCHES=( "${FILESDIR}/flutter-engine-${PV}-fix.patch" )\n'
                'HELPER="${FILESDIR}/${PF}-helper.py"\n',
            )
            files = source / "dev-libs/flutter-engine/files"
            (files / "flutter-engine-3.47.2-fix.patch").write_text("patch\n")
            (files / "flutter-engine-3.47.2-r1-helper.py").write_text("helper\n")

            carried = carry_forward_versioned_files(
                previous, "3.48.0", source, work, "dev-libs/flutter-engine"
            )

            self.assertEqual(
                (work / "dev-libs/flutter-engine/files/flutter-engine-3.48.0-fix.patch").read_text(),
                "patch\n",
            )
            self.assertEqual(
                (work / "dev-libs/flutter-engine/files/flutter-engine-3.48.0-helper.py").read_text(),
                "helper\n",
            )
            self.assertEqual(len(carried), 2)

    def test_missing_referenced_asset_fails_closed(self):
        with tempfile.TemporaryDirectory() as source_td, tempfile.TemporaryDirectory() as work_td:
            source = Path(source_td)
            work = Path(work_td)
            previous = self.make_package(
                source,
                "dev-lang/dart",
                "dart-3.13.3.ebuild",
                'PATCHES=( "${FILESDIR}/${P}-missing.patch" )\n',
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
                'PATCHES=( "${FILESDIR}/${P}-fix.patch" )\n',
            )
            source_file = source / "dev-lang/dart/files/dart-3.13.3-fix.patch"
            source_file.write_text("old\n")
            destination = work / "dev-lang/dart/files/dart-3.14.0-fix.patch"
            destination.parent.mkdir(parents=True)
            destination.write_text("different\n")

            with self.assertRaises(FileExistsError):
                carry_forward_versioned_files(
                    previous, "3.14.0", source, work, "dev-lang/dart"
                )


if __name__ == "__main__":
    unittest.main()
