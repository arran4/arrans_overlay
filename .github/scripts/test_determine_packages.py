#!/usr/bin/env python3

import json
import os
import subprocess


HELPER = ".github/scripts/determine_packages.py"


def run_helper(paths):
    env = os.environ.copy()
    env["CHANGED_FILES"] = " ".join(paths)
    result = subprocess.run(
        ["python3", HELPER],
        check=True,
        capture_output=True,
        text=True,
        env=env,
    )
    matrix = json.loads(result.stdout)
    assert all(set(entry) == {"group", "packages", "cache_id"} for entry in matrix)
    assert all(entry["cache_id"] for entry in matrix)
    return matrix


def entry(matrix, group):
    return next(item for item in matrix if item["group"] == group)


generic = run_helper(["app-misc/example/example-1.0.ebuild"])
assert generic[0]["packages"] == "=app-misc/example-1.0"

python = run_helper(["dev-python/materialyoucolor/materialyoucolor-3.0.4.ebuild"])
assert python[0]["group"] == "caelestia-python"

fonts = run_helper(["media-fonts/rubik/rubik-1.0-r1.ebuild"])
assert fonts[0]["group"] == "caelestia-fonts"

mixed = run_helper([
    "app-misc/example/example-1.0.ebuild",
    "gui-apps/caelestia-shell/caelestia-shell-2.3.0.ebuild",
    "dev-python/materialyoucolor/materialyoucolor-3.0.4.ebuild",
    "media-fonts/material-symbols-variable/material-symbols-variable-0_p20260724.ebuild",
])
assert [item["group"] for item in mixed] == [
    "caelestia-core", "caelestia-python", "caelestia-fonts", "generic-0"
]

for forced_path in (
    ".github/workflows/gentoo-pkg-test.yml",
    ".github/scripts/determine_packages.py",
):
    forced = run_helper([forced_path])
    assert [item["group"] for item in forced] == ["caelestia-core"]
    forced_packages = forced[0]["packages"].split()
    assert [package.split("/", 1)[1].rsplit("-", 1)[0] for package in forced_packages] == [
        "quickshell",
        "caelestia-shell",
        "caelestia-cli",
        "caelestia-meta",
    ]

prefixed = run_helper(["./app-misc/example/example-1.0.ebuild"])
assert prefixed == generic

duplicated = run_helper([
    "app-misc/example/example-1.0.ebuild",
    "./app-misc/example/example-1.0.ebuild",
])
assert duplicated == generic

generic_paths = [f"app-misc/package-{index:02d}/package-{index:02d}-1.ebuild" for index in range(23)]
chunked = run_helper(list(reversed(generic_paths)))
assert [item["group"] for item in chunked] == ["generic-0", "generic-1", "generic-2"]
assert max(len(item["packages"].split()) for item in chunked) <= 10
assert [package for item in chunked for package in item["packages"].split()] == sorted(
    package for item in chunked for package in item["packages"].split()
)
assert chunked == run_helper(generic_paths)

complete_core = run_helper([
    "gui-apps/caelestia-meta/caelestia-meta-1.ebuild",
    "gui-apps/caelestia-cli/caelestia-cli-1.1.2.ebuild",
    "gui-apps/caelestia-shell/caelestia-shell-2.3.0.ebuild",
    "gui-apps/quickshell/quickshell-0.3.0_p20260710.ebuild",
])
assert entry(complete_core, "caelestia-core")["packages"].split() == [
    "=gui-apps/quickshell-0.3.0_p20260710",
    "=gui-apps/caelestia-shell-2.3.0",
    "=gui-apps/caelestia-cli-1.1.2",
    "=gui-apps/caelestia-meta-1",
]

same_set_a = run_helper(generic_paths[:2])
same_set_b = run_helper(list(reversed(generic_paths[:2])))
different_set = run_helper(generic_paths[1:3])
assert same_set_a[0]["cache_id"] == same_set_b[0]["cache_id"]
assert same_set_a[0]["cache_id"] != different_set[0]["cache_id"]

print("determine_packages tests passed")
