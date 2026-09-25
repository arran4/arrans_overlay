import importlib.util
from pathlib import Path
import sys
import unittest

GENERATOR = Path(__file__).with_name("generate_flutter_engine_ebuild.py")
EBUILD = (
    Path(__file__).parents[1]
    / "dev-libs"
    / "flutter-engine"
    / "flutter-engine-3.47.2.ebuild"
)
SPEC = importlib.util.spec_from_file_location(
    "flutter_engine_ebuild_generator", GENERATOR
)
assert SPEC is not None and SPEC.loader is not None
generator = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = generator
SPEC.loader.exec_module(generator)


class ReviewedExclusionTest(unittest.TestCase):
    def test_unchanged_reviewed_cipd_exclusion_succeeds(self):
        dependency = {
            "packages": [
                {
                    "package": "gn/gn/${{platform}}",
                    "version": (
                        "git_revision:"
                        "81b24e01531ecf0eff12ec9359a555ec3944ec4e"
                    ),
                }
            ],
            "dep_type": "cipd",
        }

        reason = generator.validate_reviewed_exclusion(
            "engine/src/flutter/third_party/gn", dependency
        )

        self.assertEqual(reason, "provided by dev-build/gn")

    def test_unchanged_reviewed_git_exclusion_succeeds(self):
        dependency = {
            "url": (
                "https://chromium.googlesource.com/external/github.com/google/"
                "googletest@e9907112b47255d50b4d343e7e2160bce8dc85d1"
            ),
            "dep_type": "git",
        }

        reason = generator.validate_reviewed_exclusion(
            "engine/src/flutter/third_party/googletest", dependency
        )

        self.assertEqual(reason, "unit tests only; --no-enable-unittests")

    def test_unbundled_libraries_reviewed_and_excluded(self):
        unbundled = [
            "engine/src/flutter/third_party/angle",
            "engine/src/flutter/third_party/freetype2",
            "engine/src/flutter/third_party/libjpeg-turbo/src",
            "engine/src/flutter/third_party/libpng",
            "engine/src/flutter/third_party/libtess2",
            "engine/src/flutter/third_party/rapidjson",
        ]
        for dest in unbundled:
            self.assertIn(dest, generator.REVIEWED_EXCLUSIONS)
            _, reason = generator.REVIEWED_EXCLUSIONS[dest]
            self.assertTrue(
                "unbundled" in reason
                or "system GLES" in reason
                or "provided by dev-libs/rapidjson" in reason,
                f"unexpected reason for {dest}: {reason}",
            )

    def test_changed_cipd_version_fails(self):
        dependency = {
            "packages": [
                {
                    "package": "gn/gn/${{platform}}",
                    "version": "git_revision:" + "9" * 40,
                }
            ],
            "dep_type": "cipd",
        }

        with self.assertRaisesRegex(ValueError, "DEPS exclusion changed"):
            generator.validate_reviewed_exclusion(
                "engine/src/flutter/third_party/gn", dependency
            )

    def test_changed_cipd_package_fails(self):
        dependency = {
            "packages": [
                {
                    "package": "gn/gn/other-platform",
                    "version": (
                        "git_revision:"
                        "81b24e01531ecf0eff12ec9359a555ec3944ec4e"
                    ),
                }
            ],
            "dep_type": "cipd",
        }

        with self.assertRaisesRegex(ValueError, "DEPS exclusion changed"):
            generator.validate_reviewed_exclusion(
                "engine/src/flutter/third_party/gn", dependency
            )

    def test_changed_git_revision_fails(self):
        dependency = {
            "url": (
                "https://chromium.googlesource.com/external/github.com/google/"
                "googletest@" + "0" * 40
            ),
            "dep_type": "git",
        }

        with self.assertRaisesRegex(ValueError, "DEPS exclusion changed"):
            generator.validate_reviewed_exclusion(
                "engine/src/flutter/third_party/googletest", dependency
            )

    def test_unreviewed_exclusion_fails(self):
        dependency = {
            "url": "https://example.com/repo@" + "a" * 40,
            "dep_type": "git",
        }

        with self.assertRaisesRegex(ValueError, "unreviewed DEPS exclusion"):
            generator.validate_reviewed_exclusion(
                "engine/src/flutter/third_party/unknown", dependency
            )


class RenderTest(unittest.TestCase):
    def setUp(self):
        scratch_dir = Path(
            "/home/user/.gemini/antigravity-cli/brain/"
            "78d7929b-833a-417f-bfb0-86c4aa9ad304/scratch"
        )
        self.scratch_deps = scratch_dir / "DEPS"

    def test_exclusion_audit_complete_and_accurate(self):
        if not self.scratch_deps.exists():
            self.skipTest("scratch/DEPS not available")
        namespace = generator.load_deps(self.scratch_deps)
        active = generator.active_dependencies(namespace)
        active_destinations = {dest for dest, _ in active}

        for dest, review in generator.REVIEWED_EXCLUSIONS.items():
            self.assertIn(
                dest,
                active_destinations,
                f"reviewed exclusion {dest} is not active in DEPS",
            )

    def test_icu_shared_with_dart(self):
        if not self.scratch_deps.exists():
            self.skipTest("scratch/DEPS not available")
        rendered = generator.render(self.scratch_deps)
        self.assertIn(
            'ICU_REV="a86a32e67b8d1384b33f8fa48c83a6079b86f8cd"',
            rendered,
        )
        self.assertIn("dart-dep-icu-a86a32e6.tar.gz", rendered)
        self.assertIn(
            '"chromium-icu-${ICU_REV}|flutter/third_party/icu"',
            rendered,
        )

    def test_unbundled_libraries_excluded_from_render(self):
        if not self.scratch_deps.exists():
            self.skipTest("scratch/DEPS not available")
        rendered = generator.render(self.scratch_deps)
        excluded_keys = [
            "ANGLE_REV",
            "FREETYPE2_REV",
            "LIBJPEG_TURBO_REV",
            "LIBPNG_REV",
            "LIBTESS2_REV",
        ]
        for key in excluded_keys:
            self.assertNotIn(key, rendered)

    def test_parent_dependency_trees_precede_subdirectories(self):
        if not self.scratch_deps.exists():
            self.skipTest("scratch/DEPS not available")
        rendered = generator.render(self.scratch_deps)
        tree_lines = []
        in_trees = False
        for line in rendered.splitlines():
            if line.strip() == "FLUTTER_ENGINE_DEPENDENCY_TREES=(":
                in_trees = True
                continue
            if in_trees:
                if line.strip() == ")":
                    break
                content = line.strip().strip('"')
                if "|" in content:
                    dest = content.split("|", 1)[1]
                    tree_lines.append(dest)

        self.assertTrue(
            tree_lines, "No dependency trees found in rendered output"
        )

        resolved = []
        for dest in tree_lines:
            res = (
                dest.replace(
                    "${DART_PKG_DIR}",
                    "flutter/third_party/dart/third_party/pkg",
                )
                .replace(
                    "${DART_TP_DIR}",
                    "flutter/third_party/dart/third_party",
                )
                .replace(
                    "${VK_DEPS_DIR}",
                    "flutter/third_party/vulkan-deps",
                )
            )
            resolved.append(res)

        for i, dest_i in enumerate(resolved):
            for j in range(i + 1, len(resolved)):
                dest_j = resolved[j]
                self.assertFalse(
                    dest_i.startswith(dest_j.rstrip("/") + "/"),
                    f"Parent directory {dest_j} appears after "
                    f"child directory {dest_i}",
                )

    def test_all_lines_under_80_columns(self):
        if not self.scratch_deps.exists():
            self.skipTest("scratch/DEPS not available")
        rendered = generator.render(self.scratch_deps)
        for tab_size in (4, 8):
            for index, line in enumerate(rendered.splitlines(), 1):
                expanded_len = len(line.expandtabs(tab_size))
                self.assertLessEqual(
                    expanded_len,
                    80,
                    f"Line {index} exceeds 80 cols ({expanded_len}) with "
                    f"tab_size={tab_size}: {line}",
                )

    def test_generator_script_lines_under_80_columns(self):
        script_text = GENERATOR.read_text()
        for tab_size in (4, 8):
            for index, line in enumerate(script_text.splitlines(), 1):
                expanded_len = len(line.expandtabs(tab_size))
                self.assertLessEqual(
                    expanded_len,
                    80,
                    f"Gen line {index} exceeds 80 cols ({expanded_len}) with "
                    f"tab_size={tab_size}: {line}",
                )

    def test_render_matches_ebuild_when_ebuild_exists(self):
        if not EBUILD.exists():
            self.skipTest(f"{EBUILD} does not exist yet")
        if not self.scratch_deps.exists():
            self.skipTest("scratch/DEPS not available")
        rendered = generator.render(self.scratch_deps)
        ebuild_text = EBUILD.read_text()
        self.assertIn(rendered, ebuild_text)

    def test_check_mode_returns_zero(self):
        if not EBUILD.exists() or not self.scratch_deps.exists():
            self.skipTest("Ebuild or DEPS missing")
        rendered = generator.render(self.scratch_deps)
        exit_code = generator.update_ebuild(rendered, check=True)
        self.assertEqual(exit_code, 0)


class ToolchainConfigurationTest(unittest.TestCase):
    def setUp(self):
        self.ebuild_text = EBUILD.read_text()
        self.patch = (
            EBUILD.parent
            / "files"
            / "flutter-engine-3.47.2-system-gcc-prefix.patch"
        )
        self.patch_text = self.patch.read_text()

    def test_ebuild_omits_gcc_config_and_exports_portage_tools(self):
        self.assertNotIn(
            "gcc-config -B",
            self.ebuild_text,
            "ebuild must not derive tool paths from gcc-config -B",
        )
        self.assertIn(
            "tc-export AR CC CXX NM RANLIB READELF STRIP",
            self.ebuild_text,
            "ebuild must export Portage toolchain variables",
        )

    def test_ebuild_configures_individual_portage_tools(self):
        expected_gn_args = [
            '--gn-args="toolchain_prefix=\\"${CHOST}-\\""',
            '--gn-args="target_cc=\\"$(tc-getCC)\\""',
            '--gn-args="target_cxx=\\"$(tc-getCXX)\\""',
            '--gn-args="target_ar=\\"$(tc-getAR)\\""',
            '--gn-args="target_nm=\\"$(tc-getNM)\\""',
            '--gn-args="target_readelf=\\"$(tc-getREADELF)\\""',
            '--gn-args="target_ld=\\"$(tc-getCXX)\\""',
            '--gn-args="target_strip=\\"$(tc-getSTRIP)\\""',
        ]
        for arg in expected_gn_args:
            self.assertIn(arg, self.ebuild_text)

    def test_ebuild_validates_toolchain_in_src_configure(self):
        self.assertIn("gcc-bin.*/(ar|nm|readelf|strip)", self.ebuild_text)
        self.assertIn("missing generated ${ninja_file}", self.ebuild_text)
        self.assertIn("type -P", self.ebuild_text)

    def test_patch_declares_target_tools_and_fixes_prefixes(self):
        self.assertIn("target_ar = \"\"", self.patch_text)
        self.assertIn("target_cc = \"\"", self.patch_text)
        self.assertIn("target_cxx = \"\"", self.patch_text)
        self.assertIn("-no-canonical-prefixes", self.patch_text)
        self.assertIn("build/config/gcc/BUILD.gn", self.patch_text)
        self.assertIn("build/toolchain/linux/BUILD.gn", self.patch_text)

    def test_impeller_compiler_deps_materialized(self):
        self.assertNotIn(
            "engine/src/flutter/third_party/inja",
            generator.REVIEWED_EXCLUSIONS,
            "inja is required by impeller/compiler and must not be excluded",
        )
        self.assertNotIn(
            "engine/src/flutter/third_party/json",
            generator.REVIEWED_EXCLUSIONS,
            "json is required by inja/impeller and must not be excluded",
        )
        self.assertIn("flutter-dep-inja-", self.ebuild_text)
        self.assertIn("flutter-dep-json-", self.ebuild_text)
        self.assertIn(
            "inja-${INJA_REV}|flutter/third_party/inja",
            self.ebuild_text,
        )
        self.assertIn(
            "json-${JSON_REV}|flutter/third_party/json",
            self.ebuild_text,
        )

    def test_vulkan_memory_allocator_materialized(self):
        self.assertNotIn(
            "engine/src/flutter/third_party/vulkan_memory_allocator",
            generator.REVIEWED_EXCLUSIONS,
            "vulkan_memory_allocator is required by flutter_vma",
        )
        self.assertIn(
            "flutter-dep-vulkan-memory-allocator-",
            self.ebuild_text,
        )
        self.assertIn(
            "${VK_VMA_SRC}|flutter/third_party/vulkan_memory_allocator",
            self.ebuild_text,
        )

    def test_impeller_compiler_and_no_werror_patches_configured(self):
        compiler_patch = (
            EBUILD.parent
            / "files"
            / "flutter-engine-3.47.2-gcc-impeller-compiler.patch"
        )
        werror_patch = (
            EBUILD.parent
            / "files"
            / "flutter-engine-3.47.2-gcc-no-werror.patch"
        )
        dl_patch = (
            EBUILD.parent
            / "files"
            / "flutter-engine-3.47.2-gcc-display-list.patch"
        )
        self.assertTrue(
            compiler_patch.exists(),
            "gcc-impeller-compiler patch must exist",
        )
        self.assertTrue(
            werror_patch.exists(),
            "gcc-no-werror patch must exist",
        )
        self.assertTrue(
            dl_patch.exists(),
            "gcc-display-list patch must exist",
        )
        compiler_text = compiler_patch.read_text()
        werror_text = werror_patch.read_text()
        dl_text = dl_patch.read_text()

        self.assertIn("reflector.cc", compiler_text)
        self.assertIn("location >= resources.size()", compiler_text)
        self.assertIn("runtime_stage_data.cc", compiler_text)
        self.assertIn("kTargetPlatformKey", compiler_text)
        self.assertIn("types.cc", compiler_text)
        self.assertIn("FML_UNREACHABLE()", compiler_text)

        self.assertIn("-Werror", werror_text)
        self.assertIn("cstring", werror_text)
        self.assertIn("build/config/compiler/BUILD.gn", werror_text)

        self.assertIn("dl_storage.h", dl_text)
        self.assertIn("dl_storage.cc", dl_text)
        self.assertIn("dl_vertices.h", dl_text)
        self.assertIn("dl_vertices.cc", dl_text)
        self.assertIn("#include <cstring>", dl_text)

        self.assertIn(
            "flutter-engine-${PV}-gcc-impeller-compiler.patch",
            self.ebuild_text,
        )
        self.assertIn(
            "flutter-engine-${PV}-gcc-no-werror.patch",
            self.ebuild_text,
        )
        self.assertIn(
            "flutter-engine-${PV}-gcc-display-list.patch",
            self.ebuild_text,
        )


if __name__ == "__main__":
    unittest.main()
