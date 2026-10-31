import urllib.request
import json
import re
import subprocess
import os

def get_latest_release():
    url = "https://api.github.com/repos/arran4/klookup/releases"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                if data and isinstance(data, list) and len(data) > 0:
                    tag = data[0].get("tag_name")
                    if tag and tag.startswith('v'):
                        return tag[1:]
                    return tag
    except Exception as e:
        print(f"Error fetching releases: {e}")
    return None

def version_exists(version):
    ebuild_path = f"app-misc/klookup/klookup-{version}.ebuild"
    return os.path.exists(ebuild_path)

def generate_ebuild(version):
    template = f"""# Copyright 2024-2026 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="KDE Plasma 6 lookup tool with search providers"
HOMEPAGE="https://github.com/arran4/klookup"
SRC_URI="https://github.com/arran4/klookup/archive/refs/tags/v${{PV}}.tar.gz -> ${{P}}.tar.gz"

LICENSE="GPL-3+ BSD-2 CC-BY-SA-4.0 CC0-1.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	kde-frameworks/extra-cmake-modules:0
	virtual/pkgconfig
"
DEPEND="
	dev-qt/qtbase:6[dbus,gui,network,widgets]
	dev-qt/qtdeclarative:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kconfig:6
	kde-frameworks/kdbusaddons:6
	kde-frameworks/kglobalaccel:6
	kde-frameworks/ki18n:6
	kde-frameworks/knotifications:6
	kde-frameworks/krunner:6
	kde-frameworks/kwallet:6
	kde-frameworks/kwidgetsaddons:6
	kde-frameworks/kxmlgui:6
"
RDEPEND="${{DEPEND}}"
"""
    ebuild_path = f"app-misc/klookup/klookup-{version}.ebuild"
    os.makedirs(os.path.dirname(ebuild_path), exist_ok=True)
    with open(ebuild_path, "w") as f:
        f.write(template)
    print(f"Generated {ebuild_path}")
    return ebuild_path

def update_manifest_and_cache(version):
    # Just standard tool invocations. Note that g2 commands are skipped during mocking via subprocess
    print("Updating Manifest and MD5 cache...")
    subprocess.run(["go", "run", "github.com/arran4/g2/cmd/g2@latest", "manifest", "generate", "app-misc/klookup"], check=False)
    subprocess.run(["go", "run", "github.com/arran4/g2/cmd/g2@latest", "cache", "generate", "app-misc/klookup"], check=False)

def create_pull_request(version):
    # This logic operates in GitHub Actions via Peter Evans action or similar usually,
    # however the requirement mentions doing it here via GITHUB_TOKEN if we script it manually
    print(f"Release {version} generated, preparing PR...")
    # Typically we'd use GH CLI or API.
    # The action `.github/workflows/app-misc-klookup-update.yaml` handles git commit and peter-evans/create-pull-request

if __name__ == "__main__":
    release = get_latest_release()
    print(f"Latest release: {release}")
    if release and not version_exists(release):
        generate_ebuild(release)
        update_manifest_and_cache(release)
        create_pull_request(release)
    else:
        print("No updates needed.")
