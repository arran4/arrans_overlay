import re
import shutil
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
            self.assertIn(f'FLUTTER_ENGINE_REV="{spec.engine_revision}"', flutter_text)
            self.assertIn('FLUTTER_DART_SDK_VERSION="3.13.7"', flutter_text)
            self.assertIn('~dev-libs/flutter-engine-3.47.8', flutter_text)
            self.assertIn('"dartSdkVersion": "${FLUTTER_DART_SDK_VERSION}"', flutter_text)
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


if __name__ == "__main__":
    unittest.main()
