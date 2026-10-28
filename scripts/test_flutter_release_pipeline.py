import json
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPTS = Path(__file__).parent
sys.path.insert(0, str(SCRIPTS))

import check_flutter_engine_dart_pins as pin_check
import generate_flutter_ebuild as flutter_generator
import generate_flutter_engine_ebuild as engine_generator
import update_flutter_source as updater
from flutter_release_spec import FlutterReleaseSpec


ROOT = SCRIPTS.parent
FLUTTER_OLD = ROOT / "dev-lang/flutter/flutter-3.47.2-r1.ebuild"
ENGINE_OLD = ROOT / "dev-libs/flutter-engine/flutter-engine-3.47.2-r1.ebuild"


def release_3_47_8() -> FlutterReleaseSpec:
    return FlutterReleaseSpec(
        version="3.47.8",
        framework_revision="737ba8f885dc774b53b442759999a312c9461e4e",
        engine_revision="cf636b1dfb818dd6a3ff16e390e93b1a036969c8",
        dart_revision="416e33b0ffaef062a60ec966bb8c82ed2b83f128",
        dart_sdk_version="3.13.7",
        material_fonts_revision="3012db47f3130e62f7cc0beabff968a33cbec8d8",
        gradle_wrapper_revision="fd5c1f2c013565a3bea56ada6df9d2b8e96d56aa",
        release_date="2026-10-23T19:02:25.384067Z",
        host_dart_constraint="^3.11.0-0",
        framework_commit_date="2026-10-23T04:37:31Z",
        engine_commit_date="2026-10-23T02:13:38Z",
    )


class FlutterReleasePipelineTest(unittest.TestCase):
    def test_3_47_2_to_3_47_8_regenerates_all_release_identities(self):
        spec = release_3_47_8()
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            flutter_dir = root / "dev-lang/flutter"
            engine_dir = root / "dev-libs/flutter-engine"
            flutter_dir.mkdir(parents=True)
            engine_dir.mkdir(parents=True)
            flutter_ebuild = flutter_dir / "flutter-3.47.8.ebuild"
            engine_ebuild = engine_dir / "flutter-engine-3.47.8.ebuild"
            shutil.copy2(FLUTTER_OLD, flutter_ebuild)
            shutil.copy2(ENGINE_OLD, engine_ebuild)

            flutter_block = flutter_generator.render_pub_deps(
                flutter_generator.PUB_DEPENDENCIES, spec,
            )
            self.assertEqual(
                flutter_generator.update_ebuild(
                    flutter_ebuild, flutter_block, check=True, release=spec,
                ),
                1,
            )
            self.assertEqual(
                flutter_generator.update_ebuild(
                    flutter_ebuild, flutter_block, check=False, release=spec,
                ),
                0,
            )

            old_block = re.search(
                rf"{re.escape(engine_generator.BEGIN)}.*?{re.escape(engine_generator.END)}",
                ENGINE_OLD.read_text(), re.DOTALL,
            )
            assert old_block is not None
            engine_block = old_block.group(0).replace(
                'SDK_REV="60a57cd42d64dc03e9f07aa60a2e250755c1ef28"',
                f'SDK_REV="{spec.dart_revision}"',
            )
            old_ebuild = engine_generator.EBUILD
            try:
                engine_generator.EBUILD = engine_ebuild
                self.assertEqual(
                    engine_generator.update_ebuild(
                        engine_block, check=True, release=spec,
                    ),
                    1,
                )
                self.assertEqual(
                    engine_generator.update_ebuild(
                        engine_block, check=False, release=spec,
                    ),
                    0,
                )
                self.assertEqual(
                    engine_generator.update_ebuild(
                        engine_block, check=True, release=spec,
                    ),
                    0,
                )
            finally:
                engine_generator.EBUILD = old_ebuild

            flutter_text = flutter_ebuild.read_text()
            self.assertIn(f'FLUTTER_GIT_COMMIT="{spec.framework_revision}"', flutter_text)
            self.assertIn(f'FLUTTER_FRAMEWORK_COMMIT_DATE="{spec.framework_commit_date}"', flutter_text)
            self.assertIn(f'FLUTTER_ENGINE_REV="{spec.engine_revision}"', flutter_text)
            self.assertIn(f'FLUTTER_ENGINE_COMMIT_DATE="{spec.engine_commit_date}"', flutter_text)
            self.assertIn('FLUTTER_DART_SDK_VERSION="3.13.7"', flutter_text)
            self.assertIn('FLUTTER_RELEASE_DATE="2026-10-23T19:02:25.384067Z"', flutter_text)
            self.assertIn('~dev-libs/flutter-engine-3.47.8', flutter_text)
            self.assertIn('"dartSdkVersion": "${FLUTTER_DART_SDK_VERSION}"', flutter_text)
            self.assertIn('"frameworkCommitDate": "${FLUTTER_FRAMEWORK_COMMIT_DATE}"', flutter_text)
            self.assertIn('"engineCommitDate": "${FLUTTER_ENGINE_COMMIT_DATE}"', flutter_text)
            self.assertIn('"engineBuildDate": "${build_date}"', flutter_text)
            self.assertNotIn('"engineContentHash"', flutter_text)
            self.assertIn('"build_date": "${build_date}"', flutter_text)
            self.assertIn('"build_time_ms": ${build_time_ms}', flutter_text)
            self.assertIn('"git_revision_date": "${FLUTTER_ENGINE_COMMIT_DATE}"', flutter_text)
            self.assertNotIn('"content_hash"', flutter_text)
            self.assertIn(f'FLUTTER_ENGINE_REV="{spec.engine_revision}"',
                          engine_ebuild.read_text())
            self.assertIn(f'SDK_REV="{spec.dart_revision}"',
                          engine_ebuild.read_text())

            pin_check.validate_generated_ebuilds(
                flutter_ebuild, spec.version, spec.framework_revision,
                spec.engine_revision, spec.dart_revision, spec.dart_sdk_version,
            )

    def test_check_rejects_stale_identity_outside_generated_blocks(self):
        spec = release_3_47_8()
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "flutter-3.47.8.ebuild"
            shutil.copy2(FLUTTER_OLD, target)
            block = flutter_generator.render_pub_deps(
                flutter_generator.PUB_DEPENDENCIES, spec,
            )
            flutter_generator.update_ebuild(target, block, False, spec)
            target.write_text(target.read_text().replace(
                f'~dev-libs/flutter-engine-{spec.version}',
                '~dev-libs/flutter-engine-3.47.2',
            ))
            self.assertEqual(
                flutter_generator.update_ebuild(target, block, True, spec), 1,
            )

    def test_release_spec_rejects_flutter_engine_dart_pin_mismatch(self):
        release = {
            "version": "3.47.8",
            "hash": "737ba8f885dc774b53b442759999a312c9461e4e",
            "dart_sdk_version": "3.13.7",
            "release_date": "2026-10-23T19:02:25.384067Z",
        }
        with patch.object(
            updater, "get_flutter_internal_version",
            side_effect=[
                "cf636b1dfb818dd6a3ff16e390e93b1a036969c8",
                "flutter/fonts/3012db47f3130e62f7cc0beabff968a33cbec8d8/fonts.zip",
                "gradle-wrapper/fd5c1f2c013565a3bea56ada6df9d2b8e96d56aa/gradle-wrapper.tgz",
            ],
        ), patch.object(
            updater, "get_deps_dart_revision",
            side_effect=["a" * 40, "b" * 40],
        ), patch.object(
            updater, "check_dart_compatibility", return_value="^3.11.0-0",
        ):
            with self.assertRaisesRegex(ValueError, "different Dart revisions"):
                updater.build_release_spec(release)

    def test_refresh_updates_existing_pr_without_recreating_it(self):
        commands = []

        def run(cmd, **kwargs):
            commands.append(cmd)
            if cmd[:3] == ["git", "status", "--porcelain"]:
                return updater.subprocess.CompletedProcess(cmd, 0, "")
            return updater.subprocess.CompletedProcess(cmd, 0, "")

        with patch.object(updater, "run_cmd", side_effect=run):
            self.assertTrue(updater.commit_and_push(
                "auto-update-flutter-source-3.47.8", "3.47.2-r1", "3.47.8",
                "a" * 40, "b" * 40, "c" * 40, "d" * 40, "e" * 40,
                "^3.11.0-0", False, refresh=True,
            ))
        self.assertTrue(any(cmd[:3] == ["gh", "pr", "edit"] for cmd in commands))
        self.assertFalse(any(cmd[:3] == ["gh", "pr", "create"] for cmd in commands))
        self.assertFalse(any(cmd[:3] == ["git", "push", "origin"] for cmd in commands))

    def test_gentoo_revision_ebuild_support(self):
        spec = release_3_47_8()
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            flutter_dir = root / "dev-lang/flutter"
            engine_dir = root / "dev-libs/flutter-engine"
            flutter_dir.mkdir(parents=True)
            engine_dir.mkdir(parents=True)
            flutter_ebuild = flutter_dir / "flutter-3.47.8-r1.ebuild"
            engine_ebuild = engine_dir / "flutter-engine-3.47.8-r1.ebuild"
            shutil.copy2(FLUTTER_OLD, flutter_ebuild)
            shutil.copy2(ENGINE_OLD, engine_ebuild)

            flutter_block = flutter_generator.render_pub_deps(
                flutter_generator.PUB_DEPENDENCIES, spec,
            )
            self.assertEqual(
                flutter_generator.update_ebuild(
                    flutter_ebuild, flutter_block, check=False, release=spec,
                ),
                0,
            )

            old_block = re.search(
                rf"{re.escape(engine_generator.BEGIN)}.*?{re.escape(engine_generator.END)}",
                ENGINE_OLD.read_text(), re.DOTALL,
            )
            assert old_block is not None
            engine_block = old_block.group(0).replace(
                'SDK_REV="60a57cd42d64dc03e9f07aa60a2e250755c1ef28"',
                f'SDK_REV="{spec.dart_revision}"',
            )
            old_ebuild = engine_generator.EBUILD
            try:
                engine_generator.EBUILD = engine_ebuild
                self.assertEqual(
                    engine_generator.update_ebuild(
                        engine_block, check=False, release=spec,
                    ),
                    0,
                )
            finally:
                engine_generator.EBUILD = old_ebuild

            pin_check.validate_generated_ebuilds(
                flutter_ebuild, "3.47.8-r1", spec.framework_revision,
                spec.engine_revision, spec.dart_revision, spec.dart_sdk_version,
            )

    def test_workflow_input_compatibility_check(self):
        with tempfile.TemporaryDirectory() as tmp:
            wf_path = Path(tmp) / "test-workflow.yaml"
            wf_path.write_text(
                "on:\n  workflow_dispatch:\n    inputs:\n      flutter_version:\n        type: string\n"
            )
            self.assertTrue(updater.workflow_declares_input(wf_path, "flutter_version"))
            self.assertFalse(updater.workflow_declares_input(wf_path, "nonexistent"))

            legacy_wf = Path(tmp) / "legacy-workflow.yaml"
            legacy_wf.write_text("on:\n  workflow_dispatch:\n")
            self.assertFalse(updater.workflow_declares_input(legacy_wf, "flutter_version"))

            commands = []
            def fake_run(cmd, **kwargs):
                commands.append(cmd)
                return updater.subprocess.CompletedProcess(cmd, 0, "")

            with patch.object(updater, "run_cmd", side_effect=fake_run):
                updater.trigger_release_validation(
                    "branch-foo", "3.47.8", repo_root=Path(tmp)
                )
            # Legacy workflows lacking inputs are dispatched without -f flutter_version
            for cmd in commands:
                self.assertNotIn("-f", cmd)

    def test_e2e_refresh_historical_branch_simulation(self):
        """Simulate refreshing an older PR branch that has old generator scripts without --release-spec."""
        spec = release_3_47_8()
        with tempfile.TemporaryDirectory() as tmp:
            repo_dir = Path(tmp) / "repo"
            repo_dir.mkdir()

            def git(*args):
                subprocess.run(["git", *args], cwd=str(repo_dir), check=True, capture_output=True)

            git("init", "-b", "main")
            git("config", "user.name", "Test")
            git("config", "user.email", "test@example.com")
            git("config", "commit.gpgsign", "false")

            # Setup main directory structure with current scripts and workflows
            scripts_dir = repo_dir / "scripts"
            wf_dir = repo_dir / ".github" / "workflows"
            flutter_dir = repo_dir / "dev-lang" / "flutter"
            engine_dir = repo_dir / "dev-libs" / "flutter-engine"
            virtual_dir = repo_dir / "virtual" / "flutter"
            dart_dir = repo_dir / "dev-lang" / "dart"
            for d in (scripts_dir, wf_dir, flutter_dir, engine_dir, virtual_dir, dart_dir):
                d.mkdir(parents=True)

            for s in ROOT.glob("scripts/*.py"):
                shutil.copy2(s, scripts_dir)
            for w in ROOT.glob(".github/workflows/*.yaml"):
                shutil.copy2(w, wf_dir)
            shutil.copy2(FLUTTER_OLD, flutter_dir / "flutter-3.47.2-r1.ebuild")
            shutil.copy2(ENGINE_OLD, engine_dir / "flutter-engine-3.47.2-r1.ebuild")
            shutil.copytree(ROOT / "dev-libs/flutter-engine/files", engine_dir / "files")
            shutil.copytree(ROOT / "dev-lang/flutter/files", flutter_dir / "files")
            (virtual_dir / "flutter-3.47.2.ebuild").write_text('RDEPEND="|| ( ~dev-lang/flutter-3.47.2 ~dev-lang/flutter-bin-3.47.2 )"\n')
            (dart_dir / "dart-3.13.7.ebuild").write_text('EAPI=8\n')
            git("add", ".")
            git("commit", "-m", "Initial main commit")

            # Create historical branch
            branch_name = "auto-update-flutter-source-3.47.8"
            git("checkout", "-b", branch_name)

            # Revert scripts on this branch to old generator without --release-spec
            old_engine_script = (
                "#!/usr/bin/env python3\n"
                "import sys, argparse\n"
                "parser = argparse.ArgumentParser()\n"
                "parser.add_argument('--ebuild')\n"
                "args, unknown = parser.parse_known_args()\n"
                "if '--release-spec' in sys.argv:\n"
                "    raise RuntimeError('unrecognized argument: --release-spec')\n"
                "print('old engine generator')\n"
            )
            (scripts_dir / "generate_flutter_engine_ebuild.py").write_text(old_engine_script)
            if (scripts_dir / "flutter_release_spec.py").exists():
                (scripts_dir / "flutter_release_spec.py").unlink()

            # Create initial 3.47.8 ebuild on branch with stale metadata
            shutil.copy2(FLUTTER_OLD, flutter_dir / "flutter-3.47.8.ebuild")
            shutil.copy2(ENGINE_OLD, engine_dir / "flutter-engine-3.47.8.ebuild")
            git("add", ".")
            git("commit", "-m", "dev-lang/flutter: bump to 3.47.8 (source)")

            # Checkout back to main
            git("checkout", "main")

            commands = []
            orig_run_cmd = updater.run_cmd
            def fake_run_cmd(cmd, **kwargs):
                commands.append(cmd)
                if cmd[:3] == ["git", "status", "--porcelain"]:
                    return updater.subprocess.CompletedProcess(cmd, 0, "")
                if cmd[:3] == ["git", "ls-remote", "--exit-code"]:
                    return updater.subprocess.CompletedProcess(cmd, 0, "")
                if cmd[:3] == ["gh", "pr", "list"]:
                    return updater.subprocess.CompletedProcess(cmd, 0, json.dumps([{"url": "https://github.com/test/pr/978"}]))
                if cmd[:2] == ["gh", "pr"] or cmd[:3] == ["gh", "workflow", "run"]:
                    return updater.subprocess.CompletedProcess(cmd, 0, "")
                if cmd[:2] == ["git", "fetch"] or cmd[:2] == ["git", "push"]:
                    return updater.subprocess.CompletedProcess(cmd, 0, "")
                if cmd[:3] == ["git", "checkout", "-B"]:
                    res = subprocess.run(["git", "checkout", cmd[3]], cwd=str(repo_dir), capture_output=True, text=True, check=True)
                    return updater.subprocess.CompletedProcess(cmd, res.returncode, res.stdout, res.stderr)
                if len(cmd) > 1 and "generate_flutter_engine_ebuild.py" in str(cmd[1]):
                    spec = FlutterReleaseSpec.read(Path(cmd[cmd.index("--release-spec") + 1]))
                    ebuild_path = Path(cmd[cmd.index("--ebuild") + 1])
                    check = "--check" in cmd
                    engine_generator.EBUILD = ebuild_path
                    old_block = re.search(
                        rf"{re.escape(engine_generator.BEGIN)}.*?{re.escape(engine_generator.END)}",
                        ebuild_path.read_text(), re.DOTALL,
                    )
                    assert old_block is not None
                    block = old_block.group(0).replace(
                        'SDK_REV="60a57cd42d64dc03e9f07aa60a2e250755c1ef28"',
                        f'SDK_REV="{spec.dart_revision}"',
                    )
                    ret = engine_generator.update_ebuild(block, check, spec)
                    return updater.subprocess.CompletedProcess(cmd, ret, "")
                if len(cmd) > 1 and "generate_flutter_ebuild.py" in str(cmd[1]):
                    spec = FlutterReleaseSpec.read(Path(cmd[cmd.index("--release-spec") + 1]))
                    ebuild_path = Path(cmd[cmd.index("--ebuild") + 1])
                    check = "--check" in cmd
                    block = flutter_generator.render_pub_deps(flutter_generator.PUB_DEPENDENCIES, spec)
                    ret = flutter_generator.update_ebuild(ebuild_path, block, check, spec)
                    return updater.subprocess.CompletedProcess(cmd, ret, "")
                if len(cmd) > 1 and "verify_manifest.py" in str(cmd[1]):
                    return updater.subprocess.CompletedProcess(cmd, 0, "")
                if cmd[0] == "git":
                    res = subprocess.run(cmd, cwd=str(repo_dir), capture_output=True, text=True, check=kwargs.get("check", True))
                    return updater.subprocess.CompletedProcess(cmd, res.returncode, res.stdout, res.stderr)
                return orig_run_cmd(cmd, **kwargs)

            with patch.object(updater, "REPO_ROOT", repo_dir), \
                 patch.object(updater, "run_cmd", side_effect=fake_run_cmd), \
                 patch.object(updater, "get_flutter_release", return_value={
                     "version": "3.47.8",
                     "hash": spec.framework_revision,
                     "dart_sdk_version": spec.dart_sdk_version,
                     "release_date": spec.release_date,
                 }), \
                 patch.object(updater, "build_release_spec", return_value=spec), \
                 patch.object(updater, "check_superseding_release", return_value=False), \
                 patch.object(updater, "check_pr_exists", return_value=True), \
                 patch.object(updater, "check_branch_exists", return_value=True), \
                 patch.object(flutter_generator, "fetch_pub_deps", return_value=flutter_generator.PUB_DEPENDENCIES):

                ret = updater.main(["--refresh", "--version", "3.47.8"])
                self.assertEqual(ret, 0)

            refreshed_flutter = (flutter_dir / "flutter-3.47.8.ebuild").read_text()
            self.assertIn(f'FLUTTER_GIT_COMMIT="{spec.framework_revision}"', refreshed_flutter)
            self.assertIn(f'FLUTTER_FRAMEWORK_COMMIT_DATE="{spec.framework_commit_date}"', refreshed_flutter)
            self.assertIn('"engineBuildDate": "${build_date}"', refreshed_flutter)
            self.assertNotIn('"engineContentHash"', refreshed_flutter)
            self.assertTrue((scripts_dir / "flutter_release_spec.py").exists())


if __name__ == "__main__":
    unittest.main()
