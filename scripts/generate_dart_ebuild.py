#!/usr/bin/env python3
"""Regenerate the pinned Dart DEPS source graph in the ebuild.

To update Dart, change DART_VERSION and DART_EBUILD_REVISION together, then
review every DEPS identity before regenerating.  The exact reviewed exclusions
intentionally prevent this script from pretending an unreviewed version bump
is automatic.

Conditions are evaluated for the only supported source build: Linux/amd64,
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


DART_VERSION = "3.13.3"
DART_EBUILD_REVISION = 1
BOOTSTRAP_SDK_TAG = "version:3.13.0-103.1.beta"
SDK_DEPS_URL = (
    "https://raw.githubusercontent.com/dart-lang/sdk/"
    f"{DART_VERSION}/DEPS"
)
EBUILD = (
    Path(__file__).parents[1]
    / "dev-lang"
    / "dart"
    / f"dart-{DART_VERSION}-r{DART_EBUILD_REVISION}.ebuild"
)
BEGIN = "# BEGIN GENERATED DART DEPS"
END = "# END GENERATED DART DEPS"


@dataclass(frozen=True)
class DependencyIdentity:
    """The complete reviewed identity of one deliberately excluded DEPS entry."""

    dep_type: str
    repository: str | None = None
    revision: str | None = None
    packages: tuple[tuple[str, str], ...] = ()
    condition: str | None = None


@dataclass(frozen=True)
class GitSource:
    """One pinned Git archive and its destination in the Dart source tree."""

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


# These active entries are deliberately not materialized as normal sources.
# Each review is bound to the exact upstream type, repository/package,
# revision/version, and condition.  Any identity change requires a new review.
REVIEWED_EXCLUSIONS: dict[str, tuple[DependencyIdentity, str]] = {
    "sdk/tools/sdks/dart-sdk": (
        cipd_identity(
            "dart/dart-sdk/${{platform}}",
            "version:3.13.0-103.1.beta",
        ),
        "provided by dev-lang/dart-bootstrap-bin",
    ),
    "sdk/third_party/d8/linux/x64": (
        cipd_identity("dart/third_party/d8/linux-amd64", "version:15.1.137"),
        "JavaScript-engine tests only",
    ),
    "sdk/third_party/d8/linux/arm64": (
        cipd_identity("dart/third_party/d8/linux-arm64", "version:15.1.137"),
        "JavaScript-engine tests only",
    ),
    "sdk/third_party/d8/macos/x64": (
        cipd_identity("dart/third_party/d8/mac-amd64", "version:15.1.137"),
        "JavaScript-engine tests only",
    ),
    "sdk/third_party/d8/macos/arm64": (
        cipd_identity("dart/third_party/d8/mac-arm64", "version:15.1.137"),
        "JavaScript-engine tests only",
    ),
    "sdk/third_party/d8/windows/x64": (
        cipd_identity("dart/third_party/d8/windows-amd64", "version:15.1.137"),
        "JavaScript-engine tests only",
    ),
    "sdk/third_party/devtools": (
        cipd_identity(
            "dart/third_party/flutter/devtools",
            "git_revision:12d595649f189f1896722623f72599077f476848",
        ),
        "replaced by the pinned devtools_shared source package",
    ),
    "sdk/tests/co19/src": (
        cipd_identity(
            "dart/third_party/co19",
            "git_revision:4e646407a6ab60d1eabfc0c39e39caf0ed7b147e",
        ),
        "language conformance tests only",
    ),
    "sdk/third_party/gsutil": (
        cipd_identity("infra/3pp/tools/gsutil", "version:3@5.35"),
        "release-bot upload helper only",
    ),
    "sdk/buildtools/sysroot/linux": (
        cipd_identity(
            "fuchsia/third_party/sysroot/linux",
            "git_revision:fa7a5a9710540f30ff98ae48b62f2cdf72ed2acd",
            "host_os == linux",
        ),
        "system root selected by --no-clang",
    ),
    "sdk/buildtools/sysroot/focal": (
        cipd_identity(
            "fuchsia/third_party/sysroot/focal",
            "git_revision:fa7a5a9710540f30ff98ae48b62f2cdf72ed2acd",
            "host_os == linux",
        ),
        "riscv64 sysroot; amd64-only package",
    ),
    "sdk/buildtools/linux-x64/clang": (
        cipd_identity(
            "fuchsia/third_party/clang/linux-amd64",
            "git_revision:deb6854eec93529b2bd30178d400ad2ee7665cd4",
        ),
        "system GCC selected by --no-clang",
    ),
    "sdk/buildtools/reclient-linux": (
        cipd_identity(
            "infra/rbe/client/linux-amd64",
            "re_client_version:28341fc74c68f05a5c8be35160ada940c4edb969",
            'host_os == "linux"',
        ),
        "remote execution disabled",
    ),
    "sdk/buildtools": (
        cipd_identity(
            "gn/gn/${{platform}}",
            "git_revision:b8becbd4f7979f63ab3542524b2b4d8db2ce3b52",
            "host_os != 'win'",
        ),
        "provided by dev-build/gn",
    ),
    "sdk/buildtools/ninja": (
        cipd_identity(
            "infra/3pp/tools/ninja/${{platform}}",
            "version:3@1.13.2.chromium.4",
        ),
        "provided by dev-build/ninja",
    ),
    "sdk/benchmarks/NativeCall/native/out/": (
        cipd_identity(
            "dart/benchmarks/nativecall",
            "w1JKzCIHSfDNIjqnioMUPq0moCXKwX67aUfhyrvw4E0C",
        ),
        "benchmark fixture only",
    ),
    "sdk/benchmarks/FfiBoringssl/native/out/": (
        cipd_identity(
            "dart/benchmarks/ffiboringssl",
            "commit:a86c69888b9a416f5249aacb4690a765be064969",
        ),
        "benchmark fixture only",
    ),
    "sdk/benchmarks/FfiCall/native/out/": (
        cipd_identity(
            "dart/benchmarks/fficall",
            "ebF5aRXKDananlaN4Y8b0bbCNHT1MnkGbWqfpCpiND4C",
        ),
        "benchmark fixture only",
    ),
    "sdk/pkg/front_end/test/types/benchmark_data": (
        cipd_identity(
            "dart/cfe/benchmark_data",
            "sha1sum:a0832fe5edeb158bf63dbe3ec10cf5d00186b3ff",
        ),
        "test fixture only",
    ),
    "sdk/buildtools/clang_format/script": (
        git_identity(
            "https://chromium.googlesource.com/chromium/llvm-project/cfe/"
            "tools/clang-format.git",
            "bb994c6f067340c1135eb43eed84f4b33cfa7397",
        ),
        "source-formatting helper only",
    ),
    "sdk/third_party/jinja2": (
        git_identity(
            "https://chromium.googlesource.com/chromium/src/third_party/"
            "jinja2.git",
            "2222b31554f03e62600cd7e383376a7c187967a1",
        ),
        "DOM generator and VM wiki tooling only",
    ),
    "sdk/third_party/libc": (
        git_identity(
            "https://llvm.googlesource.com/llvm-project/libc",
            "5af39a19a1ad51ce93972cdab206dcd3ff9b6afa",
        ),
        "unused with the system GCC/libstdc++ toolchain",
    ),
    "sdk/third_party/libcxx": (
        git_identity(
            "https://llvm.googlesource.com/llvm-project/libcxx",
            "bd557f6f764d1e40b62528a13b124ce740624f8f",
        ),
        "unused with the system GCC/libstdc++ toolchain",
    ),
    "sdk/third_party/libcxxabi": (
        git_identity(
            "https://llvm.googlesource.com/llvm-project/libcxxabi",
            "a4dda1589d37a7e4b4f7a81ebad01b1083f2e726",
        ),
        "unused with the system GCC/libstdc++ toolchain",
    ),
    "sdk/third_party/markupsafe": (
        git_identity(
            "https://chromium.googlesource.com/chromium/src/third_party/"
            "markupsafe.git",
            "8f45f5cfa0009d2a70589bcda0349b8cb2b72783",
        ),
        "Jinja dependency only",
    ),
    "sdk/third_party/ply": (
        git_identity(
            "https://chromium.googlesource.com/chromium/src/third_party/ply.git",
            "604b32590ffad5cbb82e4afef1d305512d06ae93",
        ),
        "legacy DOM generator only",
    ),
}

SHORT_NAMES = {
    "browser-compat-data": "BROWSER_DATA",
    "clang-format": "CLANG_FORMAT",
    "chromium-src-third_party-zlib": "ZLIB",
    "chromium-icu": "ICU",
    "cpu_features": "CPU_FEATURES",
    "dart_style": "DART_STYLE",
    "devtools": "DEVTOOLS_SHARED",
    "leak_tracker": "LEAK_TRACKER",
    "protobuf.dart": "PROTOBUF",
    "sync_http": "SYNC_HTTP",
    "sync_http.dart": "SYNC_HTTP",
    "vector_math.dart": "VECTOR_MATH",
    "webdriver.dart": "WEBDRIVER",
    "webkit_inspection_protocol.dart": "WEBKIT_PROTOCOL",
}


def load_deps(path: Path) -> dict[str, object]:
    """Evaluate the data-only DEPS DSL without exposing Python builtins."""
    namespace: dict[str, object] = {
        "__builtins__": {},
        "linux": "linux",
        "mac": "mac",
        "win": "win",
        "android": "android",
    }

    def var(name: str) -> object:
        return namespace["vars"][name]  # type: ignore[index]

    namespace["Var"] = var
    exec(compile(path.read_text(), str(path), "exec"), namespace)
    variables = namespace["vars"]
    assert isinstance(variables, dict)
    variables.update(
        {
            "build_devtools_from_sources": False,
            "download_reclient": False,
        }
    )
    return namespace


def condition_is_true(condition: str | None, variables: dict[str, object]) -> bool:
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


def active_dependencies(namespace: dict[str, object]) -> list[tuple[str, object]]:
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
    condition = dependency.get("condition") if isinstance(dependency, dict) else None
    dep_type = (
        dependency.get("dep_type", "git")
        if isinstance(dependency, dict)
        else "git"
    )

    if dep_type == "git":
        url = dependency.get("url") if isinstance(dependency, dict) else dependency
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
    """Fail unless an exclusion still has the exact identity that was reviewed."""
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
        raise ValueError(f"unsupported Git DEPS entry at {destination}: {dependency!r}")
    repository, revision = url.rsplit("@", 1)
    repository = stable_github_repository(repository.removesuffix(".git"))
    relative = destination.removeprefix("sdk/")
    repository_name = repository.rstrip("/").rsplit("/", 1)[-1]
    name = SHORT_NAMES.get(repository_name)
    if name is None:
        name = re.sub(r"[^A-Za-z0-9]+", "_", repository_name).strip("_").upper()
    filename = f"dart-dep-{name.lower().replace('_', '-')}-{revision[:8]}.tar.gz"
    return GitSource(name, repository, revision, filename, relative)


def stable_github_repository(repository: str) -> str:
    """Return a content-addressed GitHub mirror with stable archive bytes."""
    external_prefixes = (
        "https://chromium.googlesource.com/external/github.com/",
        "https://dart.googlesource.com/external/github.com/",
    )
    for prefix in external_prefixes:
        if repository.startswith(prefix):
            return "https://github.com/" + repository.removeprefix(prefix)

    mirrors = {
        "https://boringssl.googlesource.com/boringssl": (
            "https://github.com/google/boringssl"
        ),
        "https://chromium.googlesource.com/chromium/deps/icu": (
            "https://github.com/librepo/chromium-icu"
        ),
        "https://chromium.googlesource.com/chromium/src/third_party/zlib": (
            "https://github.com/gsource-mirror/chromium-src-third_party-zlib"
        ),
        "https://dart.googlesource.com/protobuf": (
            "https://github.com/google/protobuf.dart"
        ),
        "https://dart.googlesource.com/sync_http": (
            "https://github.com/google/sync_http.dart"
        ),
        "https://dart.googlesource.com/webcore": (
            "https://github.com/dart-archive/webcore"
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


def render(deps_path: Path) -> str:
    namespace = load_deps(deps_path)
    variables = namespace["vars"]
    assert isinstance(variables, dict)
    if variables.get("sdk_tag") != BOOTSTRAP_SDK_TAG:
        raise ValueError(
            "Dart bootstrap changed: "
            f"expected {BOOTSTRAP_SDK_TAG!r}, got {variables.get('sdk_tag')!r}"
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
            if destination == "sdk/third_party/devtools":
                revision = str(variables["devtools_rev"])
                git_sources.append(
                    GitSource(
                        "DEVTOOLS_SHARED",
                        "https://github.com/flutter/devtools",
                        revision,
                        f"dart-dep-devtools-shared-{revision[:8]}.tar.gz",
                        "third_party/devtools/devtools_shared",
                        "packages/devtools_shared",
                    )
                )
        elif dep_type == "git":
            if destination in REVIEWED_EXCLUSIONS:
                validate_reviewed_exclusion(destination, dependency)
                active_reviews.add(destination)
            else:
                git_sources.append(git_source(destination, dependency))
        else:
            raise ValueError(f"unsupported DEPS type {dep_type!r} at {destination}")

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

    lines.extend(["", "DART_DEPENDENCY_TREES=("])
    for source in sorted(identifiers.values(), key=lambda item: item.identifier):
        lines.append(f'\t"{source.unpacked_source()}|{source.destination}"')
    lines.extend([")", "", 'SRC_URI="'])
    lines.append("\thttps://github.com/dart-lang/sdk/archive/refs/tags/${PV}.tar.gz")
    lines.append("\t\t-> ${P}.tar.gz")
    for identifier, source in sorted(identifiers.items()):
        lines.append(f"\t{source.repository}/archive/${{{identifier}_REV}}.tar.gz")
        lines.append(f"\t\t-> {source.filename}")
    lines.extend(['"', END])
    too_long = [
        (index, line)
        for index, line in enumerate(lines, 1)
        if len(line.expandtabs(8)) > 120
    ]
    if too_long:
        raise ValueError(f"generated lines exceed 120 columns: {too_long}")
    return "\n".join(lines)


def obtain_deps(
    sdk_tree: Path | None,
) -> tuple[Path, tempfile.TemporaryDirectory[str] | None]:
    if sdk_tree is not None:
        return sdk_tree / "DEPS", None

    temporary = tempfile.TemporaryDirectory(prefix="dart-deps-")
    deps_path = Path(temporary.name) / "DEPS"
    urllib.request.urlretrieve(SDK_DEPS_URL, deps_path)
    return deps_path, temporary


def update_ebuild(generated: str, check: bool) -> int:
    existing = EBUILD.read_text()
    pattern = re.compile(
        rf"^{re.escape(BEGIN)}$.*?^{re.escape(END)}$",
        re.MULTILINE | re.DOTALL,
    )
    replacement, count = pattern.subn(generated, existing)
    if count != 1:
        raise ValueError(f"expected one generated block in {EBUILD}, found {count}")
    if replacement == existing:
        return 0
    if check:
        print(
            f"{EBUILD} is not synchronized with Dart {DART_VERSION} DEPS",
            file=sys.stderr,
        )
        return 1
    EBUILD.write_text(replacement)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--sdk-tree", type=Path)
    args = parser.parse_args()
    deps_path, temporary = obtain_deps(args.sdk_tree)
    try:
        return update_ebuild(render(deps_path), args.check)
    finally:
        if temporary is not None:
            temporary.cleanup()


if __name__ == "__main__":
    raise SystemExit(main())
