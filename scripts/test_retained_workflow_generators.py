import os
import re
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
GENERATOR_SCRIPT = REPO_ROOT / "scripts" / "generate_retained_ebuild.sh"


class RetainedWorkflowGeneratorsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.tmp_path = Path(self.tmp.name)
        self.assertTrue(GENERATOR_SCRIPT.exists(), f"Missing production generator: {GENERATOR_SCRIPT}")
        self.assertTrue(os.access(GENERATOR_SCRIPT, os.X_OK), f"Generator not executable: {GENERATOR_SCRIPT}")

    def run_generator(self, *args, env=None):
        cmd = [str(GENERATOR_SCRIPT), *args]
        run_env = os.environ.copy()
        if env:
            run_env.update(env)
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=run_env)
        return res

    def test_workflow_files_call_production_generator(self):
        """Verify workflow YAMLs invoke the shared production generator rather than inline recipes."""
        for wf_name in (
            "app-misc-kjules-update.yaml",
            "app-misc-stability-matrix-appimage-update.yaml",
            "net-im-beeper-appimage-update.yaml",
        ):
            wf_path = REPO_ROOT / ".github" / "workflows" / wf_name
            self.assertTrue(wf_path.exists(), f"Workflow not found: {wf_path}")
            content = wf_path.read_text()
            self.assertIn(
                "./scripts/generate_retained_ebuild.sh",
                content,
                f"Workflow {wf_name} does not call scripts/generate_retained_ebuild.sh",
            )

        beeper_workflow = (
            REPO_ROOT / ".github" / "workflows" / "net-im-beeper-appimage-update.yaml"
        ).read_text()
        self.assertIn(
            '"$appimage_url"',
            beeper_workflow,
            "Beeper workflow must pass its discovered release URL to the generator",
        )

    def test_kjules_generator_production_execution(self):
        """Test kjules production generator execution, valid recipe, idempotence, and revision awareness."""
        pkg_dir = self.tmp_path / "kjules"
        version = "0.0.86"
        ebuild_file = pkg_dir / f"kjules-{version}.ebuild"

        # 1. Initial generation
        res = self.run_generator("kjules", str(pkg_dir), version)
        self.assertEqual(res.returncode, 0, f"Generator failed: {res.stderr}")
        self.assertIn("GENERATED:", res.stdout)
        self.assertTrue(ebuild_file.exists())

        content = ebuild_file.read_text()
        self.assertIn("EAPI=8", content)
        self.assertIn('ECM_TEST="forceoptional"', content)
        self.assertIn("inherit xdg ecm", content)
        self.assertIn("dev-qt/qtbase:6[gui,network,widgets]", content)
        self.assertIn("kde-frameworks/karchive:6", content)
        self.assertIn("kde-frameworks/kconfig:6", content)
        self.assertIn("kde-frameworks/kcoreaddons:6", content)
        self.assertIn("kde-frameworks/kdbusaddons:6", content)
        self.assertIn("kde-frameworks/kglobalaccel:6", content)
        self.assertIn("kde-frameworks/ki18n:6", content)
        self.assertIn("kde-frameworks/knotifications:6", content)
        self.assertIn("kde-frameworks/kwallet:6", content)
        self.assertIn("kde-frameworks/kwidgetsaddons:6", content)
        self.assertIn("kde-frameworks/kwindowsystem:6", content)
        self.assertIn("kde-frameworks/kxmlgui:6", content)
        self.assertEqual(subprocess.run(["bash", "-n", str(ebuild_file)]).returncode, 0)

        # 2. Repeated execution is idempotent
        before_repeat = ebuild_file.read_bytes()
        res_repeat = self.run_generator("kjules", str(pkg_dir), version)
        self.assertEqual(res_repeat.returncode, 0)
        self.assertIn("SKIPPED:", res_repeat.stdout)
        self.assertEqual(before_repeat, ebuild_file.read_bytes())

        # 3. Revision awareness: existing -r1 ebuild blocks unrevisioned recreation
        rev_dir = self.tmp_path / "kjules-rev"
        rev_dir.mkdir(parents=True)
        (rev_dir / f"kjules-{version}-r1.ebuild").write_text("# existing revision")

        res_rev = self.run_generator("kjules", str(rev_dir), version)
        self.assertEqual(res_rev.returncode, 0)
        self.assertIn("SKIPPED:", res_rev.stdout)
        self.assertFalse((rev_dir / f"kjules-{version}.ebuild").exists())

    def test_stability_matrix_generator_production_execution(self):
        """Test stability-matrix production generator, glibc handling, rename guard, and revision awareness."""
        pkg_dir = self.tmp_path / "stability-matrix"
        version = "2.16.5"
        ebuild_file = pkg_dir / f"stability-matrix-appimage-{version}.ebuild"

        # 1. Same-name scenario: archived == installed -> NO redundant rename
        res = self.run_generator(
            "stability-matrix-appimage",
            str(pkg_dir),
            version,
            "StabilityMatrix.AppImage",
            "StabilityMatrix.AppImage",
        )
        self.assertEqual(res.returncode, 0, f"Generator failed: {res.stderr}")
        self.assertIn("GENERATED:", res.stdout)
        self.assertTrue(ebuild_file.exists())

        content = ebuild_file.read_text()
        self.assertIn("EAPI=8", content)
        self.assertIn('elibc_glibc? ( sys-libs/glibc )', content)
        self.assertIn('sys-devel/gcc', content)
        self.assertIn('BDEPEND="app-arch/unzip"', content)
        self.assertIn("pkg_pretend()", content)
        self.assertIn("! use elibc_glibc", content)
        self.assertIn("v${PV}", content)
        # Production rename guard assertion: same-name MUST NOT emit mv
        self.assertNotIn('mv "StabilityMatrix.AppImage" "StabilityMatrix.AppImage"', content)
        self.assertEqual(subprocess.run(["bash", "-n", str(ebuild_file)]).returncode, 0)

        # 2. Repeated execution is idempotent
        before_repeat = ebuild_file.read_bytes()
        res_repeat = self.run_generator(
            "stability-matrix-appimage",
            str(pkg_dir),
            version,
            "StabilityMatrix.AppImage",
            "StabilityMatrix.AppImage",
        )
        self.assertEqual(res_repeat.returncode, 0)
        self.assertIn("SKIPPED:", res_repeat.stdout)
        self.assertEqual(before_repeat, ebuild_file.read_bytes())

        # 3. Different-name scenario: archived != installed -> MUST emit mv
        diff_dir = self.tmp_path / "stability-matrix-diff"
        res_diff = self.run_generator(
            "stability-matrix-appimage",
            str(diff_dir),
            version,
            "StabilityMatrix-linux-x64.AppImage",
            "StabilityMatrix.AppImage",
        )
        self.assertEqual(res_diff.returncode, 0)
        diff_ebuild = diff_dir / f"stability-matrix-appimage-{version}.ebuild"
        self.assertTrue(diff_ebuild.exists())
        diff_content = diff_ebuild.read_text()
        self.assertIn('mv "StabilityMatrix-linux-x64.AppImage" "StabilityMatrix.AppImage"', diff_content)

        # 4. Revision awareness: existing -r1 ebuild blocks recreation
        rev_dir = self.tmp_path / "stability-matrix-rev"
        rev_dir.mkdir(parents=True)
        (rev_dir / f"stability-matrix-appimage-{version}-r1.ebuild").write_text("# existing revision")

        res_rev = self.run_generator(
            "stability-matrix-appimage",
            str(rev_dir),
            version,
            "StabilityMatrix.AppImage",
            "StabilityMatrix.AppImage",
        )
        self.assertEqual(res_rev.returncode, 0)
        self.assertIn("SKIPPED:", res_rev.stdout)
        self.assertFalse((rev_dir / f"stability-matrix-appimage-{version}.ebuild").exists())

    def test_beeper_generator_production_execution(self):
        """Test beeper production generator execution, valid recipe, idempotence, and revision awareness."""
        pkg_dir = self.tmp_path / "beeper"
        version = "4.3.229"
        ebuild_file = pkg_dir / f"beeper-appimage-{version}.ebuild"

        # 1. Initial generation
        source_url = "https://download.example.invalid/releases/Beeper-4.3.229-x86_64.AppImage"
        res = self.run_generator(
            "beeper-appimage", str(pkg_dir), version, "AppImage", "beeper.AppImage", source_url
        )
        self.assertEqual(res.returncode, 0, f"Generator failed: {res.stderr}")
        self.assertIn("GENERATED:", res.stdout)
        self.assertTrue(ebuild_file.exists())

        content = ebuild_file.read_text()
        self.assertIn("EAPI=8", content)
        self.assertIn('DESCRIPTION="Beeper universal chat app"', content)
        self.assertIn(source_url, content)
        self.assertIn('newexe "${P}.AppImage" "beeper.AppImage"', content)
        self.assertEqual(subprocess.run(["bash", "-n", str(ebuild_file)]).returncode, 0)

        # 2. Repeated execution is idempotent
        before_repeat = ebuild_file.read_bytes()
        res_repeat = self.run_generator(
            "beeper-appimage", str(pkg_dir), version, "AppImage", "beeper.AppImage", source_url
        )
        self.assertEqual(res_repeat.returncode, 0)
        self.assertIn("SKIPPED:", res_repeat.stdout)
        self.assertEqual(before_repeat, ebuild_file.read_bytes())

        # 3. Revision awareness: existing -r1 ebuild blocks unrevisioned recreation
        rev_dir = self.tmp_path / "beeper-rev"
        rev_dir.mkdir(parents=True)
        (rev_dir / f"beeper-appimage-{version}-r1.ebuild").write_text("# existing revision")

        res_rev = self.run_generator(
            "beeper-appimage", str(rev_dir), version, "AppImage", "beeper.AppImage", source_url
        )
        self.assertEqual(res_rev.returncode, 0)
        self.assertIn("SKIPPED:", res_rev.stdout)
        self.assertFalse((rev_dir / f"beeper-appimage-{version}.ebuild").exists())


if __name__ == "__main__":
    unittest.main()
