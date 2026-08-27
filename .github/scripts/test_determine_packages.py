#!/usr/bin/env python3

import json
import os
import re
import subprocess


HELPER = ".github/scripts/determine_packages.py"


def run_helper(paths, source_paths=None):
    env = os.environ.copy()
    env["CHANGED_FILES"] = " ".join(paths)
    env["SOURCE_FILES"] = " ".join(paths if source_paths is None else source_paths)
    result = subprocess.run(
        ["python3", HELPER],
        check=True,
        capture_output=True,
        text=True,
        env=env,
    )
    matrix = json.loads(result.stdout)
    assert all(
        set(entry) == {"group", "package", "source_target", "cache_id"}
        for entry in matrix
    )
    assert all(entry["cache_id"] for entry in matrix)
    return matrix


generic = run_helper(["app-misc/example/example-1.0.ebuild"])
assert generic == [{
    "group": "generic",
    "package": "=app-misc/example-1.0",
    "source_target": True,
    "cache_id": generic[0]["cache_id"],
}]

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
    "caelestia-core", "caelestia-python", "caelestia-fonts", "generic"
]

for forced_path in (
    ".github/workflows/gentoo-pkg-test.yml",
    ".github/scripts/determine_packages.py",
):
    forced = run_helper([forced_path], source_paths=[])
    assert [item["group"] for item in forced] == ["caelestia-core"] * 4
    assert [item["package"] for item in forced] == [
        "gui-apps/quickshell",
        "gui-apps/caelestia-shell",
        "gui-apps/caelestia-cli",
        "gui-apps/caelestia-meta",
    ]
    assert not any(item["source_target"] for item in forced)

forced_with_changed_target = run_helper([
    ".github/workflows/gentoo-pkg-test.yml",
    "gui-apps/caelestia-shell/caelestia-shell-2.3.0.ebuild",
])
assert [item["source_target"] for item in forced_with_changed_target] == [
    False, True, False, False,
]

prefixed = run_helper(["./app-misc/example/example-1.0.ebuild"])
assert prefixed == generic

duplicated = run_helper([
    "app-misc/example/example-1.0.ebuild",
    "./app-misc/example/example-1.0.ebuild",
])
assert duplicated == generic

generic_paths = [f"app-misc/package-{index:02d}/package-{index:02d}-1.ebuild" for index in range(23)]
independent = run_helper(list(reversed(generic_paths)))
assert [item["group"] for item in independent] == ["generic"] * 23
assert [item["package"] for item in independent] == sorted(item["package"] for item in independent)
assert independent == run_helper(generic_paths)

complete_core = run_helper([
    "gui-apps/caelestia-meta/caelestia-meta-1.ebuild",
    "gui-apps/caelestia-cli/caelestia-cli-1.1.2.ebuild",
    "gui-apps/caelestia-shell/caelestia-shell-2.3.0.ebuild",
    "gui-apps/quickshell/quickshell-0.3.1.ebuild",
])
assert [item["package"] for item in complete_core] == [
    "=gui-apps/quickshell-0.3.1",
    "=gui-apps/caelestia-shell-2.3.0",
    "=gui-apps/caelestia-cli-1.1.2",
    "=gui-apps/caelestia-meta-1",
]

same_set_a = run_helper(generic_paths[:2])
same_set_b = run_helper(list(reversed(generic_paths[:2])))
different_set = run_helper(generic_paths[1:3])
assert same_set_a == same_set_b
assert len({item["cache_id"] for item in same_set_a}) == len(same_set_a)
assert same_set_a[1]["cache_id"] == different_set[0]["cache_id"]

# A logical group containing multiple changed packages retains its group
# identity but expands to independent, deduplicated execution jobs.
multi_font = run_helper([
    "media-fonts/rubik/rubik-1.0-r1.ebuild",
    "media-fonts/material-symbols-variable/material-symbols-variable-1.ebuild",
    "./media-fonts/rubik/rubik-1.0-r1.ebuild",
])
assert [item["group"] for item in multi_font] == ["caelestia-fonts"] * 2
assert [item["package"] for item in multi_font] == [
    "=media-fonts/material-symbols-variable-1",
    "=media-fonts/rubik-1.0-r1",
]
assert len({item["cache_id"] for item in multi_font}) == 2

# The workflow prefers binaries globally while forcing only directly changed
# targets to source, retaining normal fallback and targeted autounmasking.
with open(".github/workflows/gentoo-pkg-test.yml", encoding="utf-8") as workflow_file:
    workflow = workflow_file.read()
assert 'CP=$(python3 -c "import portage; print(portage.dep.Atom(\\"$PKG\\").cp)")' in workflow
assert 'PACKAGE="${{ matrix.package }}"' in workflow
assert 'SOURCE_TARGET="${{ matrix.source_target }}"' in workflow
assert "matrix.packages" not in workflow
assert "for PKG in $PACKAGES" not in workflow
assert "--getbinpkg-exclude" not in workflow
assert "--buildpkg-exclude" not in workflow
assert "--usepkgonly" not in workflow
assert "--binpkg-respect-use=n" not in workflow
assert "--binpkg-changed-deps=n" not in workflow
assert "--ignore-built-slot-operator-deps" not in workflow
assert "--with-bdeps=y" not in workflow
assert "--onlydeps" not in workflow
assert "\n            etc-update " not in workflow
package_emerge = re.search(r"if ! emerge -v \\\n(?P<options>.*?)\"\$PKG\"; then", workflow, re.DOTALL)
assert package_emerge is not None
package_emerge_options = package_emerge.group("options")
for option in (
    "--usepkg",
    "--getbinpkg",
    "--binpkg-changed-deps=y",
    "--useoldpkg-atoms='*/*'",
    "--autounmask=y",
    "--autounmask-write=y",
    "--autounmask-continue=y",
    "--backtrack=50",
):
    assert option in package_emerge_options
assert 'EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --usepkg --getbinpkg"' in workflow
assert "timeout-minutes: 120" in workflow
assert "timeout-minutes: 105" in workflow
assert workflow.count("actions/cache/restore@v4") == 1
assert workflow.count("actions/cache/save@v4") == 1
assert "if: always()\n        uses: actions/cache/save@v4" in workflow
assert "gentoo-binpkgs-v5-${{ steps.gentoo-environment.outputs.cache_id }}-${{ matrix.group }}-${{ matrix.cache_id }}-${{ github.run_id }}-${{ github.run_attempt }}" in workflow
assert """restore-keys: |
            gentoo-binpkgs-v5-${{ steps.gentoo-environment.outputs.cache_id }}-${{ matrix.group }}-${{ matrix.cache_id }}-
            gentoo-binpkgs-v4-${{ steps.gentoo-environment.outputs.cache_id }}-${{ matrix.cache_id }}-
            gentoo-binpkgs-v5-${{ steps.gentoo-environment.outputs.cache_id }}-${{ matrix.group }}-
            gentoo-binpkgs-v5-${{ steps.gentoo-environment.outputs.cache_id }}-
            gentoo-binpkgs-v4-${{ steps.gentoo-environment.outputs.cache_id }}-
""" in workflow
assert "            gentoo-binpkgs-v5-\n" not in workflow
assert "            gentoo-binpkgs-v4-\n" not in workflow
assert "gentoo-binpkgs-v3-" not in workflow
assert "dev-qt/* opengl vulkan" not in workflow
assert "TARGET_BINARY_OPTIONS+=(--usepkg-exclude \"$PKG\")" in workflow
assert 'docker exec gentoo /tmp/test_packages.sh "$PACKAGE" "$SOURCE_TARGET"' in workflow
assert 'CONFIG_PROTECT_MASK="${CONFIG_PROTECT_MASK} /etc/portage/package.accept_keywords /etc/portage/package.use /etc/portage/package.unmask"' in workflow
assert 'printf "%s ~amd64\\n" "$PKG"' in workflow
assert 'ACCEPT_KEYWORDS="~amd64"' not in workflow

print("determine_packages tests passed")
