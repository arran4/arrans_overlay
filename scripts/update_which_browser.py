#!/usr/bin/env python3
"""Update which_browser source package automatically.

Detects the latest releases from GitHub API, constructs the unauthenticated
SRC_URI, validates its accessibility, and generates an ebuild if valid.
"""

from __future__ import annotations

import json
import logging
import os
import re
import subprocess
import sys
import urllib.request
import urllib.error
from pathlib import Path

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

def run_cmd(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    logging.info(f"Running: {' '.join(cmd)}")
    kwargs.setdefault("check", True)
    kwargs.setdefault("text", True)
    return subprocess.run(cmd, **kwargs)

def get_github_releases(owner="arran4", repo="which_browser") -> list[dict]:
    cmd = ["gh", "api", f"repos/{owner}/{repo}/releases"]
    try:
        res = run_cmd(cmd, capture_output=True)
        return json.loads(res.stdout)
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to fetch releases from GitHub: {e.stderr}")
        raise

def validate_url(url: str) -> bool:
    logging.info(f"Validating URL: {url}")
    req = urllib.request.Request(url, method="HEAD")
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status == 200:
                return True
    except urllib.error.HTTPError as e:
        logging.warning(f"URL validation failed for {url} with HTTP Error: {e.code}")
    except Exception as e:
        logging.warning(f"URL validation failed for {url}: {e}")
    return False

def check_ebuild_exists(work_dir: Path, version: str) -> bool:
    for p in work_dir.glob(f"which_browser-{version}*.ebuild"):
        return True
    return False

def check_pr_exists(tag: str) -> bool:
    branch_name = f"update-which_browser-{tag}"
    try:
        res = run_cmd(["gh", "pr", "list", "--head", branch_name, "--json", "url", "--state", "open"], check=True, capture_output=True)
        prs = json.loads(res.stdout)
        return len(prs) > 0
    except subprocess.CalledProcessError as e:
        logging.error(f"gh CLI error: {e}")
        raise
    except FileNotFoundError:
        logging.error("gh CLI not available. Failing closed.")
        sys.exit(1)

def generate_ebuild(work_dir: Path, base_version: str, build_suffix: str, version: str, deb_archive: str, base_url: str):
    ebuild_content = f"""# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream changed their download host from arran4.sdf.org to
# https://which-browser-site.pages.dev, update SRC_URI accordingly.

DESCRIPTION="Which Browser? A browser selecting tool with rules to automate."
HOMEPAGE="https://which-browser-site.pages.dev"

MY_BASE_PV="${{PV%.*}}"
MY_BUILD_SUFFIX="${{PV##*.}}"

if [[ ${{MY_BASE_PV}} == ${{PV}} ]] || [[ -z ${{MY_BUILD_SUFFIX}} ]]; then
\tdie "Unexpected PV format: ${{PV}}"
fi

MY_DEB_ARCHIVE="${{PN}}-${{MY_BASE_PV}}+${{MY_BUILD_SUFFIX}}-linux.deb"

# Updated SRC_URI for new host structure: downloads/vBase/file
SRC_URI="{base_url}/${{MY_DEB_ARCHIVE}}"
LICENSE="All-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="dev-util/patchelf"
RDEPEND="|| ( dev-libs/libayatana-appindicator )"
RESTRICT="mirror"

S="${{WORKDIR}}"

inherit unpacker xdg

QA_PREBUILT="usr/share/which_browser/*"

src_prepare() {{
\tdefault
\tchmod +w usr/share/which_browser/lib/libtray_manager_plugin.so || die
\tpatchelf --replace-needed libappindicator3.so.1 \
		libayatana-appindicator3.so.1 \
		usr/share/which_browser/lib/libtray_manager_plugin.so || die
}}

src_unpack() {{
\tunpack_deb "${{MY_DEB_ARCHIVE}}"
}}

src_install() {{
\t# Install the contents of the deb package
\tcp -vr "${{S}}"/usr/ "${{D}}"/usr/

\t# Ensure the executable has the correct permissions
\tfperms 0755 /usr/share/which_browser/which_browser

\t# Create a symlink in /usr/bin for easy access
\tdosym ../share/which_browser/which_browser /usr/bin/which_browser

\t# Ensure the desktop file has the correct permissions
\tif [[ -f "${{D}}/usr/share/applications/which_browser.desktop" ]]; then
\t\tfperms 0644 /usr/share/applications/which_browser.desktop
\t\tsed -i -e '/^Version=/d' "${{D}}/usr/share/applications/which_browser.desktop" || die
\tfi

\t# Ensure the icon file has the correct permissions
\tif [[ -f "${{D}}/usr/share/icons/hicolor/256x256/apps/which_browser.png" ]]; then
\t\tfperms 0644 /usr/share/icons/hicolor/256x256/apps/which_browser.png
\tfi
}}

pkg_postinst() {{
\txdg_pkg_postinst
\teinfo "Which Browser? has been installed."
\teinfo "Please set it as the default HTTP and HTTPS handler."
}}

pkg_postrm() {{
\txdg_pkg_postrm
}}
"""

    ebuild_path = work_dir / f"which_browser-{version}.ebuild"
    ebuild_path.write_text(ebuild_content)
    logging.info(f"Generated ebuild at {ebuild_path}")

    # Upsert manifest
    try:
        run_cmd(["g2", "manifest", "upsert-from-url", f"{base_url}/{deb_archive}", deb_archive, str(work_dir)])
        logging.info("Manifest upserted successfully.")
    except Exception as e:
        logging.error(f"Failed to upsert manifest: {e}")
        # Clean up the generated ebuild if manifest generation fails
        ebuild_path.unlink(missing_ok=True)
        raise

def main():
    repo_root = Path(__file__).resolve().parents[1]
    work_dir = repo_root / "www-misc" / "which_browser"
    work_dir.mkdir(parents=True, exist_ok=True)

    try:
        releases = get_github_releases()
    except Exception:
        sys.exit(1)

    generated_version = ""
    generated_tag = ""

    for release in releases:
        assets = release.get("assets", [])
        deb_asset = next((a for a in assets if a["name"].endswith("-linux.deb")), None)

        if not deb_asset:
            continue

        filename = deb_asset["name"]
        # Extract version: which_browser-0.2.6+44-linux.deb -> 0.2.6, 44
        match = re.match(r"^which_browser-(.+?)\+([0-9]+)-linux\.deb$", filename)
        if not match:
            logging.info(f"Skipping unexpected filename format: {filename}")
            continue

        base_version = match.group(1)
        build_suffix = match.group(2)
        version = f"{base_version}.{build_suffix}"

        tag_name = release.get("tag_name", f"v{base_version}+{build_suffix}")

        # Check if already processed
        if check_ebuild_exists(work_dir, version):
            logging.info(f"Ebuild for {version} already exists. Skipping.")
            continue

        if check_pr_exists(tag_name):
            logging.info(f"PR for {tag_name} already exists. Skipping.")
            continue

        # Construct candidate URL
        # The existing workflow tried: https://which-browser-site.pages.dev/downloads/v${MY_BASE_PV}/${MY_DEB_ARCHIVE}
        base_url = f"https://which-browser-site.pages.dev/downloads/v{base_version}"
        target_url = f"{base_url}/{filename}"

        if not validate_url(target_url):
            logging.error(f"Unauthenticated download validation failed for {target_url}. Skipping version {version}.")
            continue

        try:
            generate_ebuild(work_dir, base_version, build_suffix, version, filename, base_url)
            generated_version = version
            generated_tag = release.get("tag_name", f"v{base_version}+{build_suffix}")
            # Process one valid release per run
            break
        except Exception as e:
            logging.error(f"Failed to generate ebuild for {version}: {e}")
            continue

    if generated_version:
        # Output to GitHub Actions step outputs
        if "GITHUB_OUTPUT" in os.environ:
            with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                f.write(f"generated_version={generated_version}\n")
                f.write(f"generated_tag={generated_tag}\n")
        else:
            print(f"generated_version={generated_version}")
            print(f"generated_tag={generated_tag}")

if __name__ == "__main__":
    main()
