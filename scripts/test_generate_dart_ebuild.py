import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest
from unittest import mock


GENERATOR = Path(__file__).with_name("generate_dart_ebuild.py")
EBUILD = (
    Path(__file__).parents[1]
    / "dev-lang"
    / "dart"
    / "dart-3.13.3-r1.ebuild"
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

    def test_reduced_source_closure_exclusions_succeed(self):
        cases = [
            (
                "sdk/third_party/mdn/browser-compat-data/src",
                (
                    "https://chromium.googlesource.com/external/github.com/"
                    "mdn/browser-compat-data"
                    "@ac8cae697014da1ff7124fba33b0b4245cc6cd1b"
                ),
                "DOM generator tooling only; upstream CC0-1.0",
            ),
            (
                "sdk/third_party/emsdk",
                (
                    "https://dart.googlesource.com/external/github.com/"
                    "emscripten-core/emsdk.git"
                    "@e41b8c68a248da5f18ebd03bd0420953945d52ff"
                ),
                "dart2wasm tests only; download_emscripten=False",
            ),
            (
                "sdk/third_party/WebCore",
                (
                    "https://dart.googlesource.com/webcore.git"
                    "@bcb10901266c884e7b3740abc597ab95373ab55c"
                ),
                "legacy DOM generator only",
            ),
            (
                "sdk/third_party/cpu_features/src",
                (
                    "https://chromium.googlesource.com/external/github.com/"
                    "google/cpu_features.git"
                    "@936b9ab5515dead115606559502e3864958f7f6e"
                ),
                "Android NDK stubs only; amd64 VM uses inline CPUID",
            ),
        ]
        for destination, url, expected_reason in cases:
            with self.subTest(destination=destination):
                reason = generator.validate_reviewed_exclusion(destination, url)
                self.assertEqual(reason, expected_reason)

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


class GeneratedRepresentationTest(unittest.TestCase):
    binaryen_revision = "a" * 40
    devtools_revision = "b" * 40
    devtools_dependency = {
        "packages": [
            {
                "package": "dart/third_party/flutter/devtools",
                "version": f"git_revision:{devtools_revision}",
            }
        ],
        "dep_type": "cipd",
    }

    def render_fixture(self):
        namespace = {
            "vars": {
                "sdk_tag": generator.BOOTSTRAP_SDK_TAG,
                "devtools_rev": self.devtools_revision,
            },
            "deps": {
                "sdk/third_party/binaryen/src": (
                    "https://chromium.googlesource.com/external/github.com/"
                    "WebAssembly/binaryen@"
                    f"{self.binaryen_revision}"
                ),
                "sdk/third_party/devtools": self.devtools_dependency,
            },
        }
        reviewed_exclusions = {
            "sdk/third_party/devtools": (
                generator.cipd_identity(
                    "dart/third_party/flutter/devtools",
                    f"git_revision:{self.devtools_revision}",
                ),
                "test fixture",
            )
        }
        with (
            mock.patch.object(generator, "load_deps", return_value=namespace),
            mock.patch.object(
                generator, "REVIEWED_EXCLUSIONS", reviewed_exclusions
            ),
        ):
            return generator.render(Path("unused"))

    def test_each_dependency_mapping_is_one_array_entry(self):
        rendered = self.render_fixture()
        self.assertNotIn("DART_DEPENDENCY_ARCHIVES", rendered)
        block = rendered.split("DART_DEPENDENCY_TREES=(\n", 1)[1].split(
            "\n)\n", 1
        )[0]
        entries = [line.strip().strip('"') for line in block.splitlines()]

        self.assertEqual(len(entries), 2)
        self.assertTrue(all(entry.count("|") == 1 for entry in entries))

    def test_normal_archive_root_maps_to_dart_destination(self):
        rendered = self.render_fixture()
        self.assertIn(
            '"binaryen-${BINARYEN_REV}|third_party/binaryen/src"',
            rendered,
        )

    def test_devtools_subtree_maps_to_dart_destination(self):
        rendered = self.render_fixture()
        self.assertIn(
            '"devtools-${DEVTOOLS_SHARED_REV}/packages/devtools_shared|'
            'third_party/devtools/devtools_shared"',
            rendered,
        )

    def test_rendering_and_rewriting_are_byte_stable(self):
        first = self.render_fixture()
        second = self.render_fixture()
        self.assertEqual(first, second)

        with tempfile.TemporaryDirectory() as temporary:
            ebuild = Path(temporary) / "dart.ebuild"
            ebuild.write_text(
                f"prefix\n{generator.BEGIN}\nold\n{generator.END}\nsuffix\n"
            )
            with mock.patch.object(generator, "EBUILD", ebuild):
                self.assertEqual(generator.update_ebuild(first, check=False), 0)
                after_first = ebuild.read_bytes()
                self.assertEqual(generator.update_ebuild(first, check=False), 0)
                self.assertEqual(ebuild.read_bytes(), after_first)

    def test_ebuild_uses_normal_unpacking(self):
        ebuild = EBUILD.read_text()
        self.assertIn("DART_DEPENDENCY_TREES=(\n", ebuild)
        self.assertIn("src_unpack() {\n\tdefault\n", ebuild)
        self.assertNotIn("tar -", ebuild)

    def test_excluded_dependencies_not_materialized(self):
        ebuild = EBUILD.read_text()
        for excluded in (
            "browser-compat-data",
            "BROWSER_DATA",
            "emsdk",
            "EMSDK",
            "cpu_features",
            "CPU_FEATURES",
            "webcore",
            "WEBCORE",
        ):
            self.assertNotIn(excluded, ebuild)


if __name__ == "__main__":
    unittest.main()
