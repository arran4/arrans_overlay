"""Regression tests for Manifest selection in CI."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent))
from changed_manifest_dirs import changed_manifest_dirs


class TestChangedManifestDirs(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.repo = Path(self.tmp.name)
        self.git("init", "-q")
        self.git("config", "user.name", "CI Test")
        self.git("config", "user.email", "ci-test@example.invalid")

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.repo, text=True).strip()

    def write(self, path, content):
        dest = self.repo / path
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(content, encoding="utf-8")

    def commit(self, message):
        self.git("add", "-A")
        self.git("commit", "-qm", message)
        return self.git("rev-parse", "HEAD")

    def package(self, name):
        self.write(f"{name}/pkg-1.0.ebuild", 'EAPI=8\n')
        self.write(f"{name}/Manifest", 'DIST pkg.tar.gz 42\n')

    def test_retired_package_is_ignored(self):
        self.package("app-misc/maid-appimage")
        base = self.commit("initial")
        (self.repo / "app-misc/maid-appimage/Manifest").unlink()
        (self.repo / "app-misc/maid-appimage/pkg-1.0.ebuild").unlink()
        head = self.commit("retire package")
        self.assertEqual(changed_manifest_dirs(base, head, cwd=self.repo), [])

    def test_existing_package_manifest_deletion_fails(self):
        self.package("app-misc/still-installed")
        base = self.commit("initial")
        (self.repo / "app-misc/still-installed/Manifest").unlink()
        head = self.commit("remove manifest only")
        with self.assertRaisesRegex(ValueError, "ebuilds remain"):
            changed_manifest_dirs(base, head, cwd=self.repo)

    def test_modified_manifest_is_selected(self):
        self.package("net-im/lemmy-notify-appimage")
        base = self.commit("initial")
        self.write("net-im/lemmy-notify-appimage/Manifest", "DIST pkg2.tar.gz 43\n")
        head = self.commit("modify manifest")
        self.assertEqual(
            changed_manifest_dirs(base, head, cwd=self.repo),
            ["net-im/lemmy-notify-appimage"],
        )

    def test_added_manifest_is_selected(self):
        self.write("README", "initial\n")
        base = self.commit("initial")
        self.package("app-misc/flutter-google-datastore-appimage")
        head = self.commit("new package")
        self.assertEqual(
            changed_manifest_dirs(base, head, cwd=self.repo),
            ["app-misc/flutter-google-datastore-appimage"],
        )

    def test_manifest_rename_with_leftover_ebuild_fails(self):
        self.package("app-misc/old")
        base = self.commit("initial")
        self.package("app-misc/new")
        (self.repo / "app-misc/old/Manifest").unlink()
        head = self.commit("move manifest, leave old ebuild")
        with self.assertRaisesRegex(ValueError, "ebuilds remain"):
            changed_manifest_dirs(base, head, cwd=self.repo)

    def test_unrelated_changes_do_not_trigger(self):
        self.package("app-misc/stable")
        base = self.commit("initial")
        self.write("README", "changed\n")
        head = self.commit("docs")
        self.assertEqual(changed_manifest_dirs(base, head, cwd=self.repo), [])

    def test_three_dot_pr_diff_excludes_base_only_manifest_changes(self):
        self.package("app-misc/base-only")
        base = self.commit("initial")
        self.git("checkout", "-qb", "topic")
        self.write("README", "topic change\n")
        head = self.commit("topic")
        self.git("checkout", "-q", "-")
        self.write("app-misc/base-only/Manifest", "DIST changed 52\n")
        updated_base = self.commit("base advanced")
        self.assertEqual(
            changed_manifest_dirs(updated_base, head, three_dot=True, cwd=self.repo),
            [],
        )


if __name__ == "__main__":
    unittest.main()
