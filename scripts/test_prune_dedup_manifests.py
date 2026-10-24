import tempfile
import unittest
from pathlib import Path

from prune_dedup_manifests import prune_package


class ManifestAfterDedupeTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.directory = Path(self.tmp.name) / "dev-lang/dart"
        self.directory.mkdir(parents=True)

    def write_ebuild(self, version, body):
        path = self.directory / f"dart-{version}.ebuild"
        path.write_text(body)
        return path

    def test_prunes_only_unreferenced_dist_and_preserves_hashes(self):
        self.write_ebuild("3.13.7", 'EAPI=8\nSRC_URI="https://example.com/dart.tar.gz -> dart-3.13.7.tar.gz"\n')
        manifest = self.directory / "Manifest"
        retained = "DIST dart-3.13.7.tar.gz 42 BLAKE2B abc SHA512 def\n"
        manifest.write_text(
            "AUX local.patch 5 BLAKE2B abc SHA512 def\n"
            "DIST dart-3.13.3.tar.gz 30 BLAKE2B old SHA512 old\n"
            + retained
        )
        self.assertTrue(prune_package(self.directory))
        self.assertEqual(
            manifest.read_text(),
            "AUX local.patch 5 BLAKE2B abc SHA512 def\n" + retained,
        )
        self.assertFalse(prune_package(self.directory))

    def test_refuses_missing_dist_without_touching_manifest(self):
        self.write_ebuild("3.13.7", 'EAPI=8\nSRC_URI="https://example.com/new.tar.gz"\n')
        manifest = self.directory / "Manifest"
        original = "DIST old.tar.gz 1 BLAKE2B a SHA512 b\n"
        manifest.write_text(original)
        with self.assertRaisesRegex(ValueError, "missing DIST entries"):
            prune_package(self.directory)
        self.assertEqual(manifest.read_text(), original)

    def test_refuses_unresolved_filename(self):
        self.write_ebuild("3.13.7", 'EAPI=8\nSRC_URI="https://example.com/\${UNSET}.tar.gz"\n')
        (self.directory / "Manifest").write_text("DIST a.tar.gz 1 BLAKE2B a SHA512 b\n")
        with self.assertRaisesRegex(ValueError, "unresolved DIST name"):
            prune_package(self.directory)

    def test_refuses_unknown_uri_syntax(self):
        self.write_ebuild("3.13.7", 'EAPI=8\nSRC_URI="\${NO_DEFINED_URL}"\n')
        (self.directory / "Manifest").write_text("")
        with self.assertRaisesRegex(ValueError, "cannot resolve SRC_URI"):
            prune_package(self.directory)

    def test_no_final_ebuild_refused(self):
        (self.directory / "Manifest").write_text("")
        with self.assertRaisesRegex(ValueError, "cannot prune last ebuild"):
            prune_package(self.directory)


if __name__ == "__main__":
    unittest.main()
