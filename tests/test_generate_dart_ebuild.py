import importlib.util
from pathlib import Path
import sys
import unittest


GENERATOR = (
    Path(__file__).parents[1]
    / "dev-lang"
    / "dart"
    / "files"
    / "generate-ebuild.py"
)
SPEC = importlib.util.spec_from_file_location("dart_ebuild_generator", GENERATOR)
assert SPEC is not None and SPEC.loader is not None
generator = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = generator
SPEC.loader.exec_module(generator)


class ReviewedExclusionTest(unittest.TestCase):
    def test_unchanged_reviewed_exclusion_succeeds(self):
        dependency = {
            "packages": [
                {
                    "package": "dart/dart-sdk/${{platform}}",
                    "version": "version:3.13.0-103.1.beta",
                }
            ],
            "dep_type": "cipd",
        }

        reason = generator.validate_reviewed_exclusion(
            "sdk/tools/sdks/dart-sdk", dependency
        )

        self.assertEqual(reason, "provided by dev-lang/dart-bootstrap-bin")

    def test_changed_cipd_version_fails(self):
        dependency = {
            "packages": [
                {
                    "package": "dart/dart-sdk/${{platform}}",
                    "version": "version:3.13.0-104.0.beta",
                }
            ],
            "dep_type": "cipd",
        }

        with self.assertRaisesRegex(ValueError, "DEPS exclusion changed"):
            generator.validate_reviewed_exclusion(
                "sdk/tools/sdks/dart-sdk", dependency
            )

    def test_changed_cipd_package_fails(self):
        dependency = {
            "packages": [
                {
                    "package": "dart/different-sdk/${{platform}}",
                    "version": "version:3.13.0-103.1.beta",
                }
            ],
            "dep_type": "cipd",
        }

        with self.assertRaisesRegex(ValueError, "DEPS exclusion changed"):
            generator.validate_reviewed_exclusion(
                "sdk/tools/sdks/dart-sdk", dependency
            )

    def test_changed_git_repository_or_revision_fails(self):
        destination = "sdk/third_party/libc"
        changed_repository = (
            "https://example.invalid/llvm-project/libc"
            "@5af39a19a1ad51ce93972cdab206dcd3ff9b6afa"
        )
        changed_revision = (
            "https://llvm.googlesource.com/llvm-project/libc"
            "@0000000000000000000000000000000000000000"
        )

        for dependency in (changed_repository, changed_revision):
            with self.subTest(dependency=dependency):
                with self.assertRaisesRegex(ValueError, "DEPS exclusion changed"):
                    generator.validate_reviewed_exclusion(
                        destination, dependency
                    )

    def test_unreviewed_exclusion_fails(self):
        dependency = {
            "packages": [
                {
                    "package": "dart/new-input/${{platform}}",
                    "version": "version:1",
                }
            ],
            "dep_type": "cipd",
        }

        with self.assertRaisesRegex(ValueError, "unreviewed DEPS exclusion"):
            generator.validate_reviewed_exclusion(
                "sdk/new/excluded-input", dependency
            )


if __name__ == "__main__":
    unittest.main()
