#!/usr/bin/env python3
"""Regenerate the pinned Flutter Engine DEPS source graph in the ebuild.

To update Flutter Engine, change FLUTTER_VERSION, FLUTTER_ENGINE_REV,
and review every DEPS identity before regenerating. The exact reviewed
exclusions intentionally prevent this script from pretending an unreviewed
version bump is automatic.

Conditions are evaluated for the only supported source build: Linux/amd64 host,
using the system compiler, GN, Ninja, and C library.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
import re
import sys
import tempfile
import urllib.request


FLUTTER_VERSION = "3.47.2"
FLUTTER_ENGINE_REV = "a804b261645ef8c13eb3d5c44a5c2fb0340c5539"
DART_REVISION = "60a57cd42d64dc03e9f07aa60a2e250755c1ef28"
DEPS_URL = (
    "https://raw.githubusercontent.com/flutter/flutter/"
    f"{FLUTTER_ENGINE_REV}/DEPS"
)
EBUILD = (
    Path(__file__).parents[1]
    / "dev-libs"
    / "flutter-engine"
    / f"flutter-engine-{FLUTTER_VERSION}.ebuild"
)
BEGIN = "# BEGIN GENERATED FLUTTER ENGINE DEPS"
END = "# END GENERATED FLUTTER ENGINE DEPS"


@dataclass(frozen=True)
class DependencyIdentity:
    """The complete reviewed identity of one excluded DEPS entry."""

    dep_type: str
    repository: str | None = None
    revision: str | None = None
    packages: tuple[tuple[str, str], ...] = ()
    condition: str | None = None


@dataclass(frozen=True)
class GitSource:
    """One pinned Git archive and its destination in the Engine source tree."""

    identifier: str
    repository: str
    revision: str
    filename: str
    destination: str
    subdirectory: str | None = None

    @property
    def repository_name(self) -> str:
        return self.repository.rstrip("/").rsplit("/", 1)[-1]

    def unpacked_source(self) -> str:
        source = f"{self.repository_name}-${{{self.identifier}_REV}}"
        if self.subdirectory is not None:
            source = f"{source}/{self.subdirectory}"
        return source


def cipd_identity(
    package: str,
    version: str,
    condition: str | None = None,
) -> DependencyIdentity:
    return DependencyIdentity(
        dep_type="cipd",
        packages=((package, version),),
        condition=condition,
    )


def git_identity(
    repository: str,
    revision: str,
    condition: str | None = None,
) -> DependencyIdentity:
    return DependencyIdentity(
        dep_type="git",
        repository=repository,
        revision=revision,
        condition=condition,
    )


# Active CIPD and Git dependencies deliberately excluded from materialization.
# Each review is bound to the exact upstream type, repository/package,
# revision/version, and condition. Any identity change requires a new review.
REVIEWED_EXCLUSIONS: dict[str, tuple[DependencyIdentity, str]] = {
    "engine/src/flutter/buildtools/linux-x64/clang": (
        cipd_identity(
            "fuchsia/third_party/clang/linux-amd64",
            "git_revision:80743bd43fd5b38fedc503308e7a652e23d3ec93",
            'host_os == "linux" or host_os == "mac"',
        ),
        "system GCC selected by --no-clang",
    ),
    "engine/src/flutter/prebuilts/linux-arm64/dart-sdk": (
        cipd_identity(
            "flutter/dart-sdk/linux-arm64",
            f"git_revision:{DART_REVISION}",
            'host_os == "linux" and download_dart_sdk',
        ),
        "arm64 prebuilt; amd64 build only",
    ),
    "engine/src/flutter/prebuilts/linux-x64/dart-sdk": (
        cipd_identity(
            "flutter/dart-sdk/linux-amd64",
            f"git_revision:{DART_REVISION}",
            'host_os == "linux" and download_dart_sdk',
        ),
        "provided by virtual/dart",
    ),
    "engine/src/flutter/prebuilts/linux-x64/esbuild": (
        cipd_identity(
            "flutter/tools/esbuild/linux-amd64",
            "0.19.5",
            'host_os == "linux" and download_esbuild',
        ),
        "web engine tooling only",
    ),
    "engine/src/flutter/third_party/android_tools/google-java-format": (
        cipd_identity(
            "flutter/android/google-java-format",
            "version:1.7-1",
        ),
        "Android Java formatter only",
    ),
    "engine/src/flutter/third_party/dart/third_party/devtools": (
        cipd_identity(
            "dart/third_party/flutter/devtools",
            "git_revision:12d595649f189f1896722623f72599077f476848",
        ),
        "replaced by the pinned devtools_shared source package",
    ),
    "engine/src/flutter/third_party/dart/tools/sdks/dart-sdk": (
        cipd_identity(
            "dart/dart-sdk/${{platform}}",
            "version:3.13.0-103.1.beta",
        ),
        "provided by virtual/dart",
    ),
    "engine/src/flutter/third_party/gn": (
        cipd_identity(
            "gn/gn/${{platform}}",
            "git_revision:81b24e01531ecf0eff12ec9359a555ec3944ec4e",
        ),
        "provided by dev-build/gn",
    ),
    "engine/src/flutter/third_party/google_fonts_for_unit_tests": (
        cipd_identity(
            "flutter/flutter_font_fallbacks",
            "44bd38be0bc8c189a397ca6dd6f737746a9e0c6117b96a8f84f1edf6acd1206b",
        ),
        "unit test fonts only; --no-enable-unittests",
    ),
    "engine/src/flutter/third_party/java/openjdk": (
        cipd_identity(
            "flutter/java/openjdk/${{platform}}",
            "version:21",
            'not (host_os == "linux" and host_cpu == "arm64")',
        ),
        "Android build only",
    ),
    "third_party/ninja": (
        cipd_identity(
            "infra/3pp/tools/ninja/${{platform}}",
            "version:2@1.11.1.chromium.4",
        ),
        "provided by dev-build/ninja",
    ),
    "engine/src/flutter/third_party/ai": (
        git_identity(
            "https://dart.googlesource.com/ai.git",
            "9c96bfe5f091c9451eff5b59c9bffeb2e806b875",
        ),
        "AI and prompt tooling only",
    ),
    "engine/src/flutter/third_party/angle": (
        git_identity(
            "https://flutter.googlesource.com/third_party/angle",
            "84027aca9b71c9ba335bd000dad1107b8810a511",
        ),
        "desktop embedder examples only; "
        "system GLES headers used; --no-enable-unittests",
    ),
    "engine/src/flutter/third_party/benchmark": (
        git_identity(
            "https://chromium.googlesource.com/external/github.com/google/"
            "benchmark",
            "431abd149fd76a072f821913c0340137cc755f36",
        ),
        "benchmark fixture only",
    ),
    "engine/src/flutter/third_party/cpu_features/src": (
        git_identity(
            "https://chromium.googlesource.com/external/github.com/google/"
            "cpu_features.git",
            "936b9ab5515dead115606559502e3864958f7f6e",
        ),
        "Android NDK stubs only; amd64 uses inline CPUID",
    ),
    "engine/src/flutter/third_party/depot_tools": (
        git_identity(
            "https://chromium.googlesource.com/chromium/tools/depot_tools.git",
            "580b4ff3f5cd0dcaa2eacda28cefe0f45320e8f7",
        ),
        "Chromium/Flutter bot helper tooling only",
    ),
    "engine/src/flutter/third_party/freetype2": (
        git_identity(
            "https://flutter.googlesource.com/third_party/freetype2",
            "be4bcb57914154fc1b9e2900bf8e4b516057e2b8",
        ),
        "unbundled; system media-libs/freetype",
    ),
    "engine/src/flutter/third_party/glfw": (
        git_identity(
            "https://flutter.googlesource.com/third_party/glfw",
            "9352d8fe93cd443be18157abe81f16500549aec0",
        ),
        "desktop embedder examples only; --no-build-embedder-examples",
    ),
    "engine/src/flutter/third_party/icu": (
        git_identity(
            "https://chromium.googlesource.com/chromium/deps/icu.git",
            "d578f2e8b7bd5938e21cfb6bf15c079e0aa5b738",
        ),
        "replaced by stable librepo/chromium-icu "
        "revision shared with dev-lang/dart",
    ),
    "engine/src/flutter/third_party/googletest": (
        git_identity(
            "https://chromium.googlesource.com/external/github.com/google/"
            "googletest",
            "e9907112b47255d50b4d343e7e2160bce8dc85d1",
        ),
        "unit tests only; --no-enable-unittests",
    ),
    "engine/src/flutter/third_party/gtest-parallel": (
        git_identity(
            "https://chromium.googlesource.com/external/github.com/google/"
            "gtest-parallel",
            "38191e2733d7cbaeaef6a3f1a942ddeb38a2ad14",
        ),
        "unit test runner only",
    ),
    "engine/src/flutter/third_party/imgui": (
        git_identity(
            "https://flutter.googlesource.com/third_party/imgui.git",
            "2a1b69f05748ad909f03acf4533447cac1331611",
        ),
        "embedder examples only",
    ),
    "engine/src/flutter/third_party/inja": (
        git_identity(
            "https://flutter.googlesource.com/third_party/inja",
            "88bd6112575a80d004e551c98cf956f88ff4d445",
        ),
        "unused template engine",
    ),
    "engine/src/flutter/third_party/json": (
        git_identity(
            "https://flutter.googlesource.com/third_party/json.git",
            "17d9eacd248f58b73f4d1be518ef649fe2295642",
        ),
        "unused nlohmann/json",
    ),
    "engine/src/flutter/third_party/libjpeg-turbo/src": (
        git_identity(
            "https://flutter.googlesource.com/third_party/libjpeg-turbo",
            "0fb821f3b2e570b2783a94ccd9a2fb1f4916ae9f",
        ),
        "unbundled; system media-libs/libjpeg-turbo",
    ),
    "engine/src/flutter/third_party/libpng": (
        git_identity(
            "https://flutter.googlesource.com/third_party/libpng",
            "ced6b6c0c1e24716423a417b399d3c7d4623890d",
        ),
        "unbundled; system media-libs/libpng",
    ),
    "engine/src/flutter/third_party/libtess2": (
        git_identity(
            "https://flutter.googlesource.com/third_party/libtess2",
            "725e5e08ec8751477565f1d603fd7eb9058c277c",
        ),
        "unbundled; system games-util/libtess2",
    ),
    "engine/src/flutter/third_party/libcxx": (
        git_identity(
            "https://llvm.googlesource.com/llvm-project/libcxx",
            "bd557f6f764d1e40b62528a13b124ce740624f8f",
        ),
        "unused with the system GCC/libstdc++ toolchain",
    ),
    "engine/src/flutter/third_party/libcxxabi": (
        git_identity(
            "https://llvm.googlesource.com/llvm-project/libcxxabi",
            "a4dda1589d37a7e4b4f7a81ebad01b1083f2e726",
        ),
        "unused with the system GCC/libstdc++ toolchain",
    ),
    "engine/src/flutter/third_party/llvm_libc": (
        git_identity(
            "https://llvm.googlesource.com/llvm-project/libc",
            "5af39a19a1ad51ce93972cdab206dcd3ff9b6afa",
        ),
        "unused with the system GCC/libstdc++ toolchain",
    ),
    "engine/src/flutter/third_party/ocmock": (
        git_identity(
            "https://flutter.googlesource.com/third_party/ocmock",
            "c4ec0e3a7a9f56cfdbd0aa01f4f97bb4b75c5ef8",
        ),
        "macOS/iOS Objective-C tests only",
    ),
    "engine/src/flutter/third_party/pkg/archive": (
        git_identity(
            "https://chromium.googlesource.com/external/github.com/"
            "brendan-duncan/archive.git",
            "f1d164f8f5d8aea0be620a9b1e8d300b75a29388",
        ),
        "tooling pub package only",
    ),
    "engine/src/flutter/third_party/pkg/equatable": (
        git_identity(
            "https://flutter.googlesource.com/third_party/equatable.git",
            "2117551ff3054f8edb1a58f63ffe1832a8d25623",
        ),
        "tooling pub package only",
    ),
    "engine/src/flutter/third_party/pkg/flutter_packages": (
        git_identity(
            "https://flutter.googlesource.com/mirrors/packages",
            "25454e63851fe7933f04d025606e68c1eac4fe0f",
        ),
        "tooling pub package only",
    ),
    "engine/src/flutter/third_party/pkg/gcloud": (
        git_identity(
            "https://flutter.googlesource.com/third_party/gcloud.git",
            "a5276b85c4714378e84b1fb478b8feeeb686ac26",
        ),
        "bot upload pub package only",
    ),
    "engine/src/flutter/third_party/pkg/googleapis": (
        git_identity(
            "https://flutter.googlesource.com/third_party/googleapis.dart.git",
            "526011f56d98eab183cc6075ee1392e8303e43e2",
        ),
        "bot tooling pub package only",
    ),
    "engine/src/flutter/third_party/pkg/io": (
        git_identity(
            "https://flutter.googlesource.com/third_party/io.git",
            "997a6243aad20af4238147d9ec00bf638b9169af",
        ),
        "tooling pub package only",
    ),
    "engine/src/flutter/third_party/pkg/node_preamble": (
        git_identity(
            "https://flutter.googlesource.com/third_party/"
            "node_preamble.dart.git",
            "47245865175929ec452d8058e563c267b64c3d64",
        ),
        "web tooling pub package only",
    ),
    "engine/src/flutter/third_party/pkg/process": (
        git_identity(
            "https://dart.googlesource.com/process.dart",
            "0c9aeac86dcc4e3a6cf760b76fed507107e244d5",
        ),
        "tooling pub package only",
    ),
    "engine/src/flutter/third_party/pkg/process_runner": (
        git_identity(
            "https://flutter.googlesource.com/third_party/process_runner.git",
            "f24c69efdcaf109168f23d381fa281453d2bc9b1",
        ),
        "tooling pub package only",
    ),
    "engine/src/flutter/third_party/pkg/vector_math": (
        git_identity(
            "https://dart.googlesource.com/external/github.com/google/"
            "vector_math.dart.git",
            "0a5fd95449083d404df9768bc1b321b88a7d2eef",
        ),
        "tooling pub package only",
    ),
    "engine/src/flutter/third_party/pyyaml": (
        git_identity(
            "https://flutter.googlesource.com/third_party/pyyaml.git",
            "03c67afd452cdff45b41bfe65e19a2fb5b80a0e8",
        ),
        "provided by dev-python/pyyaml",
    ),
    "engine/src/flutter/third_party/rapidjson": (
        git_identity(
            "https://flutter.googlesource.com/third_party/rapidjson",
            "47253cab97e9cfe99dbd6b90836fc11589d7d802",
        ),
        "provided by dev-libs/rapidjson",
    ),
    "engine/src/flutter/third_party/re2": (
        git_identity(
            "https://chromium.googlesource.com/external/github.com/google/re2",
            "c84a140c93352cdabbfb547c531be34515b12228",
        ),
        "unused in host_release build",
    ),
    "engine/src/flutter/third_party/sqlite": (
        git_identity(
            "https://flutter.googlesource.com/third_party/sqlite",
            "0f61bd2023ba94423b4e4c8cfb1a23de1fe6a21c",
        ),
        "unused in host_release build",
    ),
    "engine/src/flutter/third_party/vulkan-deps": (
        git_identity(
            "https://chromium.googlesource.com/vulkan-deps",
            "a9e2ca3b57aba86a22a2df1b84bf12f8cc98806e",
        ),
        "expanded into Khronos Vulkan sub-packages",
    ),
    "engine/src/flutter/third_party/vulkan_memory_allocator": (
        git_identity(
            "https://chromium.googlesource.com/external/github.com/"
            "GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator",
            "c788c52156f3ef7bc7ab769cb03c110a53ac8fcb",
        ),
        "unused in host_release (flutter_vma uses vulkan-deps)",
    ),
    "engine/src/flutter/third_party/yapf": (
        git_identity(
            "https://flutter.googlesource.com/third_party/yapf",
            "212c5b5ad8e172d2d914ae454c121c89cccbcb35",
        ),
        "Python code formatter only",
    ),
}

# Pinned Khronos Vulkan sub-dependencies aggregated by vulkan-deps.
VULKAN_DEPS_SUBPACKAGES: list[tuple[str, str, str, str]] = [
    (
        "VK_GLSLANG",
        "https://github.com/KhronosGroup/glslang",
        "a57276bf558f5cf94d3a9854ebdf5a2236849a5a",
        "flutter/third_party/vulkan-deps/glslang/src",
    ),
    (
        "VK_LUNARG_VULKANTOOLS",
        "https://github.com/LunarG/VulkanTools",
        "b9afdd8c070500c375e95acf33c79f0420d59b17",
        "flutter/third_party/vulkan-deps/lunarg-vulkantools/src",
    ),
    (
        "VK_SPIRV_CROSS",
        "https://github.com/KhronosGroup/SPIRV-Cross",
        "b8fcf307f1f347089e3c46eb4451d27f32ebc8d3",
        "flutter/third_party/vulkan-deps/spirv-cross/src",
    ),
    (
        "VK_SPIRV_HEADERS",
        "https://github.com/KhronosGroup/SPIRV-Headers",
        "01e0577914a75a2569c846778c2f93aa8e6feddd",
        "flutter/third_party/vulkan-deps/spirv-headers/src",
    ),
    (
        "VK_SPIRV_TOOLS",
        "https://github.com/KhronosGroup/SPIRV-Tools",
        "19042c8921f35f7bec56b9e5c96c5f5691588ca8",
        "flutter/third_party/vulkan-deps/spirv-tools/src",
    ),
    (
        "VK_HEADERS",
        "https://github.com/KhronosGroup/Vulkan-Headers",
        "a4f8ada9f4f97c45b8c89c57997be9cebaae65d2",
        "flutter/third_party/vulkan-deps/vulkan-headers/src",
    ),
    (
        "VK_LOADER",
        "https://github.com/KhronosGroup/Vulkan-Loader",
        "f703f919c30c5b67958d35d40a4297cb3823ed78",
        "flutter/third_party/vulkan-deps/vulkan-loader/src",
    ),
    (
        "VK_TOOLS",
        "https://github.com/KhronosGroup/Vulkan-Tools",
        "d643b80d6ba8c191bc289fdda52867c3bb3c190b",
        "flutter/third_party/vulkan-deps/vulkan-tools/src",
    ),
    (
        "VK_UTILITY_LIBRARIES",
        "https://github.com/KhronosGroup/Vulkan-Utility-Libraries",
        "4322db5906e67b57ec9c327e6afe3d98ed893df7",
        "flutter/third_party/vulkan-deps/vulkan-utility-libraries/src",
    ),
    (
        "VK_VALIDATION_LAYERS",
        "https://github.com/KhronosGroup/Vulkan-ValidationLayers",
        "951aec1ecf22dc84a99a5c8bec9223c5810cc3e1",
        "flutter/third_party/vulkan-deps/vulkan-validation-layers/src",
    ),
]

SHORT_NAMES = {
    "abseil-cpp": "ABSEIL_CPP",
    "angle": "ANGLE",
    "binaryen": "DART_BINARYEN",
    "boringssl": "BORINGSSL",
    "brotli": "BROTLI",
    "chromium-icu": "ICU",
    "chromium-src-third_party-zlib": "ZLIB",
    "core": "DART_CORE",
    "dart": "DART_SDK",
    "dart_style": "DART_STYLE",
    "dartdoc": "DARTDOC",
    "devtools": "DEVTOOLS_SHARED",
    "ecosystem": "DART_ECOSYSTEM",
    "expat": "EXPAT",
    "flatbuffers": "FLATBUFFERS",
    "freetype": "FREETYPE2",
    "freetype2": "FREETYPE2",
    "harfbuzz": "HARFBUZZ",
    "http": "DART_HTTP",
    "i18n": "DART_I18N",
    "leak_tracker": "DART_LEAK_TRACKER",
    "libexpat": "EXPAT",
    "libjpeg-turbo": "LIBJPEG_TURBO",
    "libpng": "LIBPNG",
    "libtess2": "LIBTESS2",
    "libwebp": "LIBWEBP",
    "native": "DART_NATIVE",
    "perfetto": "DART_PERFETTO",
    "protobuf.dart": "DART_PROTOBUF",
    "pub": "DART_PUB",
    "shaderc": "SHADERC",
    "shelf": "DART_SHELF",
    "skia": "SKIA",
    "swiftshader": "SWIFTSHADER",
    "sync_http.dart": "DART_SYNC_HTTP",
    "tar": "DART_TAR",
    "test": "DART_TEST",
    "tools": "DART_TOOLS",
    "vector_math.dart": "DART_VECTOR_MATH",
    "web": "DART_WEB",
    "webdriver.dart": "DART_WEBDRIVER",
    "webkit_inspection_protocol.dart": "DART_WEBKIT_PROTOCOL",
    "wuffs-mirror-release-c": "WUFFS",
}

# Named repository variables for upstream repository URLs to ensure SRC_URI
# entries remain readable and within Gentoo's 80-column limit.
REPOSITORY_VARIABLES = {
    "https://github.com/KhronosGroup/SPIRV-Cross": "KH_SPIRV_CROSS_GIT",
    "https://github.com/KhronosGroup/SPIRV-Headers": "KH_SPIRV_HEADERS_GIT",
    "https://github.com/KhronosGroup/SPIRV-Tools": "KH_SPIRV_TOOLS_GIT",
    "https://github.com/KhronosGroup/Vulkan-Headers": "KH_VK_HEADERS_GIT",
    "https://github.com/KhronosGroup/Vulkan-Loader": "KH_VK_LOADER_GIT",
    "https://github.com/KhronosGroup/Vulkan-Tools": "KH_VK_TOOLS_GIT",
    (
        "https://github.com/KhronosGroup/Vulkan-Utility-Libraries"
    ): "KH_VK_UTIL_GIT",
    (
        "https://github.com/KhronosGroup/Vulkan-ValidationLayers"
    ): "KH_VK_LAYERS_GIT",
    "https://github.com/KhronosGroup/glslang": "KH_GLSLANG_GIT",
    "https://github.com/LunarG/VulkanTools": "LUNARG_VK_TOOLS_GIT",
    "https://github.com/WebAssembly/binaryen": "BINARYEN_GIT",
    "https://github.com/dart-lang/ecosystem": "ECOSYSTEM_GIT",
    "https://github.com/dart-lang/leak_tracker": "LEAK_TRACKER_GIT",
    "https://github.com/flutter/devtools": "DEVTOOLS_GIT",
    "https://github.com/google/protobuf.dart": "PROTOBUF_GIT",
    "https://github.com/google/sync_http.dart": "SYNC_HTTP_GIT",
    "https://github.com/google/vector_math.dart": "VECTOR_MATH_GIT",
    "https://github.com/google/webdriver.dart": "WEBDRIVER_GIT",
    "https://github.com/google/webkit_inspection_protocol.dart": "WEBKIT_GIT",
    "https://github.com/google/wuffs-mirror-release-c": "WUFFS_GIT",
    (
        "https://github.com/gsource-mirror/chromium-src-third_party-zlib"
    ): "ZLIB_GIT",
}

# Named unpack source variables for dependencies with long unpack paths to keep
# FLUTTER_ENGINE_DEPENDENCY_TREES mappings readable within Gentoo's 80 cols.
UNPACK_SOURCE_VARIABLES = {
    "DEVTOOLS_SHARED": "DEVTOOLS_SHARED_SRC",
    "DART_WEBKIT_PROTOCOL": "DART_WEBKIT_SRC",
    "VK_LUNARG_VULKANTOOLS": "VK_LUNARG_SRC",
    "VK_UTILITY_LIBRARIES": "VK_UTIL_SRC",
    "VK_VALIDATION_LAYERS": "VK_VALIDATION_SRC",
}

DESTINATION_PREFIXES: list[tuple[str, str]] = [
    ("flutter/third_party/dart/third_party/pkg/", "DART_PKG_DIR"),
    ("flutter/third_party/dart/third_party/", "DART_TP_DIR"),
    ("flutter/third_party/vulkan-deps/", "VK_DEPS_DIR"),
]


def load_deps(path: Path) -> dict[str, object]:
    """Evaluate the data-only DEPS DSL without exposing Python builtins."""
    default_vars = {
        "host_os": "linux",
        "host_cpu": "x64",
    }
    namespace: dict[str, object] = {
        "__builtins__": {},
        "linux": "linux",
        "mac": "mac",
        "win": "win",
        "android": "android",
    }

    def var(name: str) -> object:
        vars_dict = namespace.get("vars")
        if isinstance(vars_dict, dict) and name in vars_dict:
            return vars_dict[name]
        if name in default_vars:
            return default_vars[name]
        raise KeyError(name)

    namespace["Var"] = var
    exec(compile(path.read_text(), str(path), "exec"), namespace)
    variables = namespace["vars"]
    assert isinstance(variables, dict)
    variables.update(default_vars)
    variables.update(
        {
            "download_android_deps": False,
            "download_fuchsia_deps": False,
            "download_windows_deps": False,
            "download_emsdk": False,
            "download_linux_deps": True,
            "build_devtools_from_sources": False,
            "download_dart_sdk": True,
            "download_esbuild": True,
            "download_jdk": True,
        }
    )
    return namespace


def condition_is_true(
    condition: str | None, variables: dict[str, object]
) -> bool:
    if not condition:
        return True
    values = {
        **variables,
        "host_os": "linux",
        "host_cpu": "x64",
        "checkout_linux": True,
        "checkout_mac": False,
        "checkout_win": False,
        "checkout_android": False,
        "linux": "linux",
        "mac": "mac",
        "win": "win",
        "android": "android",
    }
    return bool(eval(condition, {"__builtins__": {}}, values))


def active_dependencies(
    namespace: dict[str, object]
) -> list[tuple[str, object]]:
    variables = namespace["vars"]
    assert isinstance(variables, dict)
    dependencies = dict(namespace["deps"])  # type: ignore[arg-type]
    deps_os = namespace.get("deps_os", {})
    if isinstance(deps_os, dict):
        dependencies.update(deps_os.get("linux", {}))

    active = []
    for destination, dependency in dependencies.items():
        condition = (
            dependency.get("condition")
            if isinstance(dependency, dict)
            else None
        )
        if condition_is_true(condition, variables):
            active.append((str(destination), dependency))
    return sorted(active)


def dependency_identity(
    destination: str,
    dependency: object,
) -> DependencyIdentity:
    """Return the complete identity used to approve an exclusion."""
    condition = (
        dependency.get("condition") if isinstance(dependency, dict) else None
    )
    dep_type = (
        dependency.get("dep_type", "git")
        if isinstance(dependency, dict)
        else "git"
    )

    if dep_type == "git":
        url = (
            dependency.get("url")
            if isinstance(dependency, dict)
            else dependency
        )
        if not isinstance(url, str) or "@" not in url:
            raise ValueError(
                f"unsupported Git DEPS entry at {destination}: {dependency!r}"
            )
        repository, revision = url.rsplit("@", 1)
        return git_identity(repository, revision, condition)

    if dep_type == "cipd":
        if not isinstance(dependency, dict):
            raise ValueError(
                f"unsupported CIPD DEPS entry at {destination}: {dependency!r}"
            )
        raw_packages = dependency.get("packages")
        if not isinstance(raw_packages, list) or not raw_packages:
            raise ValueError(
                f"unsupported CIPD DEPS entry at {destination}: {dependency!r}"
            )
        packages: list[tuple[str, str]] = []
        for package in raw_packages:
            if not isinstance(package, dict):
                raise ValueError(
                    f"unsupported CIPD package at {destination}: {package!r}"
                )
            name = package.get("package")
            version = package.get("version")
            if not isinstance(name, str) or not isinstance(version, str):
                raise ValueError(
                    f"unsupported CIPD package at {destination}: {package!r}"
                )
            packages.append((name, version))
        return DependencyIdentity(
            dep_type="cipd",
            packages=tuple(packages),
            condition=condition,
        )

    raise ValueError(f"unsupported DEPS type {dep_type!r} at {destination}")


def validate_reviewed_exclusion(destination: str, dependency: object) -> str:
    """Fail unless an exclusion has the exact reviewed identity."""
    review = REVIEWED_EXCLUSIONS.get(destination)
    if review is None:
        raise ValueError(f"unreviewed DEPS exclusion at {destination}")
    expected, reason = review
    actual = dependency_identity(destination, dependency)
    if actual != expected:
        raise ValueError(
            f"DEPS exclusion changed at {destination}; "
            f"expected={expected!r}, actual={actual!r}"
        )
    return reason


def git_source(
    destination: str,
    dependency: object,
) -> GitSource:
    url = dependency.get("url") if isinstance(dependency, dict) else dependency
    if not isinstance(url, str) or "@" not in url:
        raise ValueError(
            f"unsupported Git DEPS entry at {destination}: {dependency!r}"
        )
    repository, revision = url.rsplit("@", 1)
    repository = stable_github_repository(repository.removesuffix(".git"))
    relative = destination.removeprefix("engine/src/")
    repository_name = repository.rstrip("/").rsplit("/", 1)[-1]
    name = SHORT_NAMES.get(repository_name)
    if name is None:
        name = re.sub(r"[^A-Za-z0-9]+", "_", repository_name).strip("_").upper()
    # Share distfile names with dev-lang/dart for identical dependencies
    if name.startswith("DART_") or name in (
        "BORINGSSL", "DEVTOOLS_SHARED", "ICU", "ZLIB"
    ):
        dist_prefix = "dart-dep-" + name.lower().replace("_", "-")
    else:
        dist_prefix = "flutter-dep-" + name.lower().replace("_", "-")
    filename = f"{dist_prefix}-{revision[:8]}.tar.gz"
    return GitSource(name, repository, revision, filename, relative)


def stable_github_repository(repository: str) -> str:
    """Return a content-addressed GitHub mirror with stable archive bytes."""
    external_prefixes = (
        "https://chromium.googlesource.com/external/github.com/",
        "https://dart.googlesource.com/external/github.com/",
        "https://skia.googlesource.com/external/github.com/",
    )
    for prefix in external_prefixes:
        if repository.startswith(prefix):
            return "https://github.com/" + repository.removeprefix(prefix)

    mirrors = {
        "https://boringssl.googlesource.com/boringssl": (
            "https://github.com/google/boringssl"
        ),
        "https://flutter.googlesource.com/third_party/angle": (
            "https://github.com/google/angle"
        ),
        "https://chromium.googlesource.com/angle/angle": (
            "https://github.com/google/angle"
        ),
        "https://chromium.googlesource.com/chromium/deps/icu": (
            "https://github.com/librepo/chromium-icu"
        ),
        (
            "https://chromium.googlesource.com/chromium/src/third_party/"
            "abseil-cpp"
        ): (
            "https://github.com/abseil/abseil-cpp"
        ),
        "https://chromium.googlesource.com/chromium/src/third_party/zlib": (
            "https://github.com/gsource-mirror/chromium-src-third_party-zlib"
        ),
        "https://chromium.googlesource.com/webm/libwebp": (
            "https://github.com/webmproject/libwebp"
        ),
        "https://dart.googlesource.com/protobuf": (
            "https://github.com/google/protobuf.dart"
        ),
        "https://dart.googlesource.com/sync_http": (
            "https://github.com/google/sync_http.dart"
        ),
        "https://flutter.googlesource.com/third_party/freetype2": (
            "https://github.com/freetype/freetype"
        ),
        "https://flutter.googlesource.com/third_party/harfbuzz": (
            "https://github.com/harfbuzz/harfbuzz"
        ),
        "https://flutter.googlesource.com/third_party/libjpeg-turbo": (
            "https://github.com/libjpeg-turbo/libjpeg-turbo"
        ),
        "https://flutter.googlesource.com/third_party/libpng": (
            "https://github.com/pnggroup/libpng"
        ),
        "https://flutter.googlesource.com/third_party/libtess2": (
            "https://github.com/memononen/libtess2"
        ),
        "https://skia.googlesource.com/skia": (
            "https://github.com/google/skia"
        ),
        "https://swiftshader.googlesource.com/SwiftShader": (
            "https://github.com/google/swiftshader"
        ),
    }
    if repository in mirrors:
        return mirrors[repository]

    dart_prefix = "https://dart.googlesource.com/"
    if repository.startswith(dart_prefix):
        return "https://github.com/dart-lang/" + repository.removeprefix(
            dart_prefix
        )

    raise ValueError(f"no stable archive mirror for {repository}")


def format_tree_destination(destination: str) -> str:
    for prefix, var in DESTINATION_PREFIXES:
        if destination.startswith(prefix):
            return f"${{{var}}}/{destination[len(prefix):]}"
    return destination


def render(deps_path: Path) -> str:
    namespace = load_deps(deps_path)
    variables = namespace["vars"]
    assert isinstance(variables, dict)
    if variables.get("dart_revision") != DART_REVISION:
        raise ValueError(
            "Pinned Dart SDK revision changed: "
            "expected "
            f"{DART_REVISION!r}, got {variables.get('dart_revision')!r}"
        )
    git_sources: list[GitSource] = []
    active_reviews: set[str] = set()

    for destination, dependency in active_dependencies(namespace):
        dep_type = (
            dependency.get("dep_type", "git")
            if isinstance(dependency, dict)
            else "git"
        )
        if dep_type == "cipd":
            validate_reviewed_exclusion(destination, dependency)
            active_reviews.add(destination)
            devtools_dest = (
                "engine/src/flutter/third_party/dart/third_party/devtools"
            )
            if destination == devtools_dest:
                revision = str(variables["dart_devtools_rev"])
                git_sources.append(
                    GitSource(
                        "DEVTOOLS_SHARED",
                        "https://github.com/flutter/devtools",
                        revision,
                        f"dart-dep-devtools-shared-{revision[:8]}.tar.gz",
                        "flutter/third_party/dart/third_party/devtools/"
                        "devtools_shared",
                        "packages/devtools_shared",
                    )
                )
        elif dep_type == "git":
            if destination in REVIEWED_EXCLUSIONS:
                validate_reviewed_exclusion(destination, dependency)
                active_reviews.add(destination)
                if destination == "engine/src/flutter/third_party/vulkan-deps":
                    for ident, repo, rev, dest in VULKAN_DEPS_SUBPACKAGES:
                        tag = ident.lower().replace("_", "-")
                        filename = f"flutter-dep-{tag}-{rev[:8]}.tar.gz"
                        git_sources.append(
                            GitSource(ident, repo, rev, filename, dest)
                        )
                elif destination == "engine/src/flutter/third_party/icu":
                    icu_rev = "a86a32e67b8d1384b33f8fa48c83a6079b86f8cd"
                    git_sources.append(
                        GitSource(
                            "ICU",
                            "https://github.com/librepo/chromium-icu",
                            icu_rev,
                            f"dart-dep-icu-{icu_rev[:8]}.tar.gz",
                            "flutter/third_party/icu",
                        )
                    )
            else:
                git_sources.append(git_source(destination, dependency))
        else:
            raise ValueError(
                f"unsupported DEPS type {dep_type!r} at {destination}"
            )

    stale_reviews = sorted(set(REVIEWED_EXCLUSIONS) - active_reviews)
    if stale_reviews:
        raise ValueError(
            "DEPS exclusion audit is out of date; "
            f"no-longer-active={stale_reviews}"
        )

    identifiers: dict[str, GitSource] = {}
    for source in git_sources:
        if source.identifier in identifiers:
            raise ValueError(f"duplicate source identifier {source.identifier}")
        identifiers[source.identifier] = source

    lines = [BEGIN]
    for identifier, source in sorted(identifiers.items()):
        lines.append(f'{identifier}_REV="{source.revision}"')

    repo_var_lines = []
    used_repo_vars: set[str] = set()
    for identifier, source in sorted(identifiers.items()):
        if source.repository in REPOSITORY_VARIABLES:
            var_name = REPOSITORY_VARIABLES[source.repository]
            if var_name not in used_repo_vars:
                used_repo_vars.add(var_name)
                repo_var_lines.append(f'{var_name}="{source.repository}"')

    path_var_lines = [
        'DART_PKG_DIR="flutter/third_party/dart/third_party/pkg"',
        'DART_TP_DIR="flutter/third_party/dart/third_party"',
        'VK_DEPS_DIR="flutter/third_party/vulkan-deps"',
    ]

    unpack_var_lines = []
    for identifier, source in sorted(identifiers.items()):
        if identifier in UNPACK_SOURCE_VARIABLES:
            var_name = UNPACK_SOURCE_VARIABLES[identifier]
            unpack_var_lines.append(f'{var_name}="{source.unpacked_source()}"')

    if repo_var_lines:
        lines.append("")
        lines.extend(sorted(repo_var_lines))

    lines.append("")
    lines.extend(path_var_lines)

    if unpack_var_lines:
        lines.append("")
        lines.extend(sorted(unpack_var_lines))

    def tree_sort_key(item: GitSource) -> tuple[int, str]:
        dest = item.destination.strip("/")
        return (dest.count("/"), dest)

    lines.extend(["", "FLUTTER_ENGINE_DEPENDENCY_TREES=("])
    for source in sorted(identifiers.values(), key=tree_sort_key):
        unpack_src = (
            f"${{{UNPACK_SOURCE_VARIABLES[source.identifier]}}}"
            if source.identifier in UNPACK_SOURCE_VARIABLES
            else source.unpacked_source()
        )
        dest_src = format_tree_destination(source.destination)
        lines.append(f'\t"{unpack_src}|{dest_src}"')
    lines.extend([")", "", 'SRC_URI="'])
    engine_archive = (
        "	https://github.com/flutter/flutter/archive/"
        + "${FLUTTER_ENGINE_REV}.tar.gz"
    )
    lines.append(engine_archive)
    lines.append("\t\t-> ${P}.tar.gz")
    for identifier, source in sorted(identifiers.items()):
        repo_expr = (
            f"${{{REPOSITORY_VARIABLES[source.repository]}}}"
            if source.repository in REPOSITORY_VARIABLES
            else source.repository
        )
        lines.append(f"\t{repo_expr}/archive/${{{identifier}_REV}}.tar.gz")
        lines.append(f"\t\t-> {source.filename}")
    lines.extend(['"', END])
    too_long = [
        (index, line)
        for index, line in enumerate(lines, 1)
        if len(line.expandtabs(8)) > 80 or len(line.expandtabs(4)) > 80
    ]
    if too_long:
        raise ValueError(f"generated lines exceed 80 columns: {too_long}")
    return "\n".join(lines)


def obtain_deps(
    deps_path_arg: Path | None,
) -> tuple[Path, tempfile.TemporaryDirectory[str] | None]:
    if deps_path_arg is not None:
        return deps_path_arg, None

    temporary = tempfile.TemporaryDirectory(prefix="flutter-deps-")
    deps_path = Path(temporary.name) / "DEPS"
    urllib.request.urlretrieve(DEPS_URL, deps_path)
    return deps_path, temporary


def update_ebuild(generated: str, check: bool) -> int:
    existing = EBUILD.read_text()
    pattern = re.compile(
        rf"^{re.escape(BEGIN)}$.*?^{re.escape(END)}$",
        re.MULTILINE | re.DOTALL,
    )
    replacement, count = pattern.subn(generated, existing)
    if count != 1:
        raise ValueError(
            f"expected one generated block in {EBUILD}, found {count}"
        )
    if replacement == existing:
        return 0
    if check:
        print(
            f"{EBUILD} is not synchronized with Flutter {FLUTTER_VERSION} DEPS",
            file=sys.stderr,
        )
        return 1
    EBUILD.write_text(replacement)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--deps", type=Path)
    args = parser.parse_args()
    deps_path, temporary = obtain_deps(args.deps)
    try:
        if not EBUILD.exists():
            print(render(deps_path))
            return 0
        return update_ebuild(render(deps_path), args.check)
    finally:
        if temporary is not None:
            temporary.cleanup()


if __name__ == "__main__":
    raise SystemExit(main())
