#!/usr/bin/env python3

import json
import os
import re
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
    assert forced[0]["packages"].split() == [
        "gui-apps/quickshell",
        "gui-apps/caelestia-shell",
        "gui-apps/caelestia-cli",
        "gui-apps/caelestia-meta",
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
    "gui-apps/quickshell/quickshell-0.3.1.ebuild",
])
assert entry(complete_core, "caelestia-core")["packages"].split() == [
    "=gui-apps/quickshell-0.3.1",
    "=gui-apps/caelestia-shell-2.3.0",
    "=gui-apps/caelestia-cli-1.1.2",
    "=gui-apps/caelestia-meta-1",
]

same_set_a = run_helper(generic_paths[:2])
same_set_b = run_helper(list(reversed(generic_paths[:2])))
different_set = run_helper(generic_paths[1:3])
assert same_set_a[0]["cache_id"] == same_set_b[0]["cache_id"]
assert same_set_a[0]["cache_id"] != different_set[0]["cache_id"]

# The workflow prefers binaries globally, including for the explicit target,
# while retaining normal Portage source fallback and targeted autounmasking.
with open(".github/workflows/gentoo-pkg-test.yml", encoding="utf-8") as workflow_file:
    workflow = workflow_file.read()
assert 'CP=$(python3 -c "import portage; print(portage.dep.Atom(\\"$PKG\\").cp)")' in workflow
assert "--usepkg-exclude" not in workflow
assert "--getbinpkg-exclude" not in workflow
assert "--buildpkg-exclude" not in workflow
assert "--usepkgonly" not in workflow
assert "--binpkg-respect-use=n" not in workflow
assert "--binpkg-changed-deps=n" not in workflow
assert "--onlydeps" not in workflow
assert "\n            etc-update " not in workflow
package_emerge = re.search(
    r"if ! emerge -v \\\n(?P<options>(?:\s+--.*\\\n)+)\s+\"\$PKG\"; then",
    workflow,
)
assert package_emerge is not None
package_emerge_options = package_emerge.group("options")
for option in (
    "--usepkg",
    "--getbinpkg",
    "--with-bdeps=y",
    "--autounmask=y",
    "--autounmask-write=y",
    "--autounmask-continue=y",
    "--backtrack=50",
):
    assert option in package_emerge_options
assert 'EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --usepkg --getbinpkg"' in workflow
assert "timeout-minutes: 120" in workflow
assert "gentoo-binpkgs-v4-${{ steps.gentoo-environment.outputs.cache_id }}-${{ matrix.cache_id }}-${{ github.run_id }}-${{ github.run_attempt }}" in workflow
assert """restore-keys: |
            gentoo-binpkgs-v4-${{ steps.gentoo-environment.outputs.cache_id }}-${{ matrix.cache_id }}-
            gentoo-binpkgs-v4-${{ steps.gentoo-environment.outputs.cache_id }}-
""" in workflow
assert "            gentoo-binpkgs-v4-\n" not in workflow
assert "gentoo-binpkgs-v3-" not in workflow
assert 'echo "dev-qt/* opengl vulkan" > /etc/portage/package.use/zz-ci-qt' in workflow
assert 'CONFIG_PROTECT_MASK="${CONFIG_PROTECT_MASK} /etc/portage/package.accept_keywords /etc/portage/package.use /etc/portage/package.unmask"' in workflow
assert 'printf "%s ~amd64\\n" "$PKG"' in workflow
assert 'ACCEPT_KEYWORDS="~amd64"' not in workflow

print("determine_packages tests passed")
