import tempfile
import unittest
from pathlib import Path

import maintain_virtuals as virtuals


class VirtualProviderTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)

    def provider(self, package, version, keywords="~amd64"):
        directory = self.root / "dev-lang" / package
        directory.mkdir(parents=True, exist_ok=True)
        path = directory / f"{package}-{version}.ebuild"
        path.write_text(f'EAPI=8\nKEYWORDS="{keywords}"\n')
        return path

    def test_source_only_never_invents_binary_compatibility(self):
        self.provider("dart", "3.13.7")
        path = virtuals.ensure_virtual(self.root, "dart", "3.13.7")
        self.assertIn("~dev-lang/dart-3.13.7", path.read_text())
        self.assertNotIn("dart-bin", path.read_text())
        self.assertIsNone(virtuals.ensure_virtual(self.root, "dart", "3.13.7"))

    def test_binary_advancement_revises_existing_virtual(self):
        self.provider("dart", "3.13.7")
        old = virtuals.ensure_virtual(self.root, "dart", "3.13.7")
        self.provider("dart-bin", "3.13.7", "~amd64 ~arm64")
        newer = virtuals.ensure_virtual(self.root, "dart", "3.13.7")
        self.assertEqual(newer.name, "dart-3.13.7-r1.ebuild")
        self.assertIn("~dev-lang/dart-bin-3.13.7", newer.read_text())
        self.assertIn("~arm64", newer.read_text())
        self.assertNotIn("dart-bin", old.read_text())

    def test_cleanup_prunes_stale_same_version_revision(self):
        self.provider("dart", "3.13.7")
        original = virtuals.ensure_virtual(self.root, "dart", "3.13.7")
        self.provider("dart-bin", "3.13.7")
        revised = virtuals.ensure_virtual(self.root, "dart", "3.13.7")
        self.provider("flutter-bin", "3.47.7")
        virtuals.prepare(self.root)
        virtuals.cleanup(self.root)
        self.assertFalse(original.exists())
        self.assertTrue(revised.exists())
        virtuals.cleanup(self.root)
        self.assertEqual(
            [p.name for p in (self.root / "virtual/dart").glob("*.ebuild")],
            ["dart-3.13.7-r1.ebuild"],
        )

    def test_dedupe_orphan_retired_when_newer_viable_provider_exists(self):
        old = self.provider("dart", "3.13.3")
        self.provider("dart-bin", "3.13.7")
        virtuals.ensure_virtual(self.root, "dart", "3.13.3")
        virtuals.prepare(self.root)
        old.unlink()  # g2 removes the redundant old source
        # Also need a viable Flutter virtual for the full cleanup pass.
        self.provider("flutter-bin", "3.47.7")
        virtuals.prepare(self.root)
        virtuals.cleanup(self.root)
        self.assertFalse(list((self.root / "virtual/dart").glob("dart-3.13.3*.ebuild")))
        self.assertTrue((self.root / "virtual/dart/dart-3.13.7.ebuild").exists())
        self.assertIn("~dev-lang/dart-bin-3.13.7",
                      (self.root / "virtual/dart/dart-3.13.7.ebuild").read_text())

    def test_cleanup_refreshes_old_flutter_virtual_when_binary_removed(self):
        src = self.provider("flutter", "3.47.2")
        old_bin = self.provider("flutter-bin", "3.47.2")
        self.provider("flutter-bin", "3.47.7")
        self.provider("dart-bin", "3.13.7")
        virtuals.prepare(self.root)
        old_virtual = virtuals.ensure_virtual(self.root, "flutter", "3.47.2")
        old_bin.unlink()
        virtuals.cleanup(self.root)
        revisions = list((self.root / "virtual/flutter").glob("flutter-3.47.2*.ebuild"))
        self.assertEqual(len(revisions), 1)
        self.assertIn("~dev-lang/flutter-3.47.2", revisions[0].read_text())
        self.assertNotIn("~dev-lang/flutter-bin-3.47.2", revisions[0].read_text())
        self.assertFalse(old_virtual.exists())
        self.assertTrue(src.exists())

    def test_cleanup_recreates_virtual_deleted_with_old_binary(self):
        # g2 can delete the virtual alongside an old binary even though
        # the source ebuild for that exact Flutter version still exists.
        self.provider("dart-bin", "3.13.7")
        source = self.provider("flutter", "3.47.2")
        old_bin = self.provider("flutter-bin", "3.47.2")
        self.provider("flutter-bin", "3.47.8")
        virtuals.prepare(self.root)
        old_virtual = virtuals.ensure_virtual(self.root, "flutter", "3.47.2")
        self.assertIn("~dev-lang/flutter-bin-3.47.2", old_virtual.read_text())

        old_bin.unlink()
        old_virtual.unlink()  # g2 also considers the older virtual redundant
        virtuals.cleanup(self.root)

        restored = self.root / "virtual/flutter/flutter-3.47.2.ebuild"
        self.assertTrue(source.exists())
        self.assertTrue(restored.exists())
        self.assertIn("~dev-lang/flutter-3.47.2", restored.read_text())
        self.assertNotIn("~dev-lang/flutter-bin-3.47.2", restored.read_text())
        newest = self.root / "virtual/flutter/flutter-3.47.8.ebuild"
        self.assertIn("~dev-lang/flutter-bin-3.47.8", newest.read_text())

        # A second cleanup should neither discard the older viable
        # virtual again nor produce unnecessary revisions.
        before = {
            path.name: path.read_text()
            for path in (self.root / "virtual/flutter").glob("*.ebuild")
        }
        virtuals.cleanup(self.root)
        after = {
            path.name: path.read_text()
            for path in (self.root / "virtual/flutter").glob("*.ebuild")
        }
        self.assertEqual(before, after)
        self.assertEqual(
            set(after), {"flutter-3.47.2.ebuild", "flutter-3.47.8.ebuild"}
        )

    def test_dedupe_snapshot_preserves_revision_history(self):
        self.provider("dart-bin", "3.13.7")
        self.provider("flutter", "3.47.2")
        old_bin = self.provider("flutter-bin", "3.47.2")
        self.provider("flutter-bin", "3.47.8")
        virtuals.prepare(self.root)
        old_virtual = virtuals.ensure_virtual(self.root, "flutter", "3.47.2")
        original_bytes = old_virtual.read_bytes()
        self.assertIn(b"~dev-lang/flutter-bin-3.47.2", original_bytes)

        # Actual scheduled sequence: g2 deletes the older virtual, but the
        # workflow snapshots and restores its previous published contents
        # before running virtual reconciliation.
        old_bin.unlink()
        old_virtual.unlink()
        old_virtual.write_bytes(original_bytes)
        virtuals.cleanup(self.root)

        revised = self.root / "virtual/flutter/flutter-3.47.2-r1.ebuild"
        self.assertTrue(revised.exists())
        self.assertFalse(old_virtual.exists())
        self.assertIn("~dev-lang/flutter-3.47.2", revised.read_text())
        self.assertNotIn("~dev-lang/flutter-bin-3.47.2", revised.read_text())
        self.assertTrue(
            (self.root / "virtual/flutter/flutter-3.47.8.ebuild").exists()
        )
        virtuals.cleanup(self.root)
        self.assertEqual(
            sorted(p.name for p in (self.root / "virtual/flutter").glob("*.ebuild")),
            ["flutter-3.47.2-r1.ebuild", "flutter-3.47.8.ebuild"],
        )

    def test_no_real_provider_rejected(self):
        with self.assertRaisesRegex(ValueError, "no real provider"):
            virtuals.ensure_virtual(self.root, "dart", "3.13.7")

    def test_cleanup_refuses_to_remove_pinned_virtual(self):
        older = self.provider("dart", "3.13.3")
        self.provider("dart-bin", "3.13.7")
        self.provider("flutter-bin", "3.47.7")
        virtuals.ensure_virtual(self.root, "dart", "3.13.3")
        virtuals.prepare(self.root)
        consumer = self.provider("flutter", "3.47.1")
        consumer.write_text('EAPI=8\nKEYWORDS="~amd64"\nRDEPEND="~virtual/dart-3.13.3"\n')
        older.unlink()
        with self.assertRaisesRegex(ValueError, "cannot retire pinned virtual"):
            virtuals.cleanup(self.root)

    def test_cleanup_refuses_missing_replacement(self):
        self.provider("dart", "3.13.3")
        self.provider("flutter-bin", "3.47.7")
        virtuals.prepare(self.root)
        (self.root / "dev-lang/dart/dart-3.13.3.ebuild").unlink()
        with self.assertRaisesRegex(ValueError, "no viable providers"):
            virtuals.cleanup(self.root)


if __name__ == "__main__":
    unittest.main()
