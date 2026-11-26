#!/usr/bin/env python3
"""Update which_browser Gentoo package automatically.

Discovers releases from the authoritative GitHub Releases API, validates release
tag and asset parity, verifies unauthenticated public download payloads, and
generates EAPI 8 ebuilds with transactional rollback safety.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import logging
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any
import urllib.error
import urllib.request

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_WORK_DIR = REPO_ROOT / "www-misc" / "which_browser"
DEFAULT_BASE_DOWNLOAD_URL = "https://which-browser-site.pages.dev/downloads"

TAG_PATTERN = re.compile(r"^v?([0-9]+(?:\.[0-9]+)+)\+([0-9]+)$")
ASSET_PATTERN = re.compile(
    r"^which_browser-([0-9]+(?:\.[0-9]+)+)\+([0-9]+)-linux\.deb$"
)


def parse_version_tuple(
    base_version: str, build_suffix: str
) -> tuple[tuple[int, ...], int]:
    """Parse base version and build suffix into an integer tuple for sorting."""
    base_parts = tuple(int(part) for part in base_version.split("."))
    build_num = int(build_suffix)
    return (base_parts, build_num)


def run_cmd(
    cmd: list[str], mask_token: str | None = None, **kwargs: Any
) -> subprocess.CompletedProcess:
    """Run a subprocess command safely with token masking in logs."""
    log_cmd = list(cmd)
    if mask_token:
        log_cmd = [arg.replace(mask_token, "***") for arg in log_cmd]
    logging.info(f"Running: {' '.join(log_cmd)}")
    kwargs.setdefault("check", True)
    kwargs.setdefault("text", True)
    return subprocess.run(cmd, **kwargs)


def get_github_releases(
    owner: str = "arran4",
    repo: str = "which_browser",
    token: str | None = None,
) -> list[dict[str, Any]]:
    """Fetch releases from GitHub API using gh CLI or unauthenticated/authenticated urllib."""
    auth_token = (
        token
        or os.environ.get("GH_TOKEN")
        or os.environ.get("PAT_TOKEN")
        or os.environ.get("GITHUB_TOKEN")
    )

    # First attempt: gh CLI if available
    gh_path = shutil.which("gh")
    if gh_path:
        env = os.environ.copy()
        if auth_token:
            env["GH_TOKEN"] = auth_token
        try:
            res = run_cmd(
                ["gh", "api", f"repos/{owner}/{repo}/releases"],
                capture_output=True,
                env=env,
                mask_token=auth_token,
            )
            return json.loads(res.stdout)
        except subprocess.CalledProcessError as e:
            logging.warning(
                f"gh api releases query failed: {e.stderr.strip() if e.stderr else e}"
            )
        except Exception as e:
            logging.warning(f"gh api execution failed: {e}")

    # Fallback attempt: urllib.request
    api_url = f"https://api.github.com/repos/{owner}/{repo}/releases"
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "arrans_overlay-which_browser_updater/1.0",
    }
    if auth_token:
        headers["Authorization"] = f"Bearer {auth_token}"

    req = urllib.request.Request(api_url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = resp.read().decode("utf-8")
            return json.loads(data)
    except Exception as e:
        logging.error(f"Failed to fetch releases from GitHub API: {e}")
        raise


def extract_candidates(releases: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Extract, strictly validate, and sort candidate releases."""
    candidates = []
    seen_gentoo_versions: set[str] = set()

    for release in releases:
        if release.get("draft"):
            logging.debug(f"Skipping draft release: {release.get('tag_name')}")
            continue
        if release.get("prerelease"):
            logging.debug(
                f"Skipping prerelease release: {release.get('tag_name')}"
            )
            continue

        tag_name = release.get("tag_name", "").strip()
        tag_match = TAG_PATTERN.match(tag_name)
        if not tag_match:
            logging.debug(f"Skipping non-matching release tag: {tag_name}")
            continue

        tag_base_version = tag_match.group(1)
        tag_build_suffix = tag_match.group(2)

        assets = release.get("assets", [])
        deb_assets = [
            a for a in assets if a.get("name", "").endswith("-linux.deb")
        ]
        if not deb_assets:
            logging.debug(f"Release {tag_name} has no linux .deb asset.")
            continue
        if len(deb_assets) > 1:
            logging.warning(
                f"Release {tag_name} has multiple linux .deb assets ({len(deb_assets)}). Ambiguous, skipping."
            )
            continue

        deb_asset = deb_assets[0]
        if deb_asset.get("state") != "uploaded":
            logging.warning(
                f"Release {tag_name} deb asset state is '{deb_asset.get('state')}' (not 'uploaded'). Skipping."
            )
            continue

        filename = deb_asset.get("name", "")
        asset_match = ASSET_PATTERN.match(filename)
        if not asset_match:
            logging.warning(
                f"Release {tag_name} deb asset filename '{filename}' is malformed. Skipping."
            )
            continue

        asset_base_version = asset_match.group(1)
        asset_build_suffix = asset_match.group(2)

        # Validate tag and asset agreement
        if (
            tag_base_version != asset_base_version
            or tag_build_suffix != asset_build_suffix
        ):
            logging.warning(
                f"Tag/asset version mismatch: tag='{tag_name}' asset='{filename}'. Skipping."
            )
            continue

        gentoo_version = f"{tag_base_version}.{tag_build_suffix}"
        if gentoo_version in seen_gentoo_versions:
            logging.warning(
                f"Conflicting release for Gentoo version {gentoo_version} detected. Skipping duplicate/conflict."
            )
            continue
        seen_gentoo_versions.add(gentoo_version)

        version_tuple = parse_version_tuple(
            tag_base_version, tag_build_suffix
        )
        candidates.append(
            {
                "tag": tag_name,
                "base_version": tag_base_version,
                "build_suffix": tag_build_suffix,
                "gentoo_version": gentoo_version,
                "version_tuple": version_tuple,
                "asset": deb_asset,
                "filename": filename,
            }
        )

    # Sort descending by version tuple
    candidates.sort(key=lambda c: c["version_tuple"], reverse=True)
    return candidates


def check_ebuild_exists(work_dir: Path, version: str) -> bool:
    """Check if an ebuild for this Gentoo PV already exists."""
    matches = list(work_dir.glob(f"which_browser-{version}*.ebuild"))
    return len(matches) > 0


def check_pr_exists(tag: str, version: str) -> bool:
    """Check if an open pull request already exists for this tag or version."""
    gh_path = shutil.which("gh")
    if not gh_path:
        return False

    branch_candidates = [
        f"update-which_browser-{tag}",
        f"update-which-browser-{tag}",
        f"update-which_browser-{version}",
        f"update-which-browser-{version}",
    ]

    for branch in branch_candidates:
        try:
            res = run_cmd(
                [
                    "gh",
                    "pr",
                    "list",
                    "--head",
                    branch,
                    "--state",
                    "open",
                    "--json",
                    "number,url",
                ],
                capture_output=True,
            )
            prs = json.loads(res.stdout)
            if prs:
                logging.info(
                    f"Found existing open PR for branch {branch}: {prs[0].get('url')}"
                )
                return True
        except Exception as e:
            logging.warning(f"Failed to check open PR for {branch}: {e}")

    return False


def verify_download(
    target_url: str,
    expected_size: int | None = None,
    expected_sha256: str | None = None,
    timeout: int = 30,
) -> tuple[bool, str]:
    """Perform real HTTP GET download into memory/tempfile and verify size, content, and checksum."""
    logging.info(f"Verifying anonymous download: {target_url}")
    req = urllib.request.Request(
        target_url,
        headers={"User-Agent": "arrans_overlay-which_browser_updater/1.0"},
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            if resp.status != 200:
                return False, f"Unexpected HTTP status {resp.status}"

            content_type = resp.headers.get("Content-Type", "").lower()
            if "html" in content_type or "xml" in content_type:
                return (
                    False,
                    f"Invalid Content-Type '{content_type}': received HTML/XML error page instead of binary package",
                )

            sha256_hasher = hashlib.sha256()
            total_bytes = 0
            first_chunk = True

            while True:
                chunk = resp.read(65536)
                if not chunk:
                    break
                if first_chunk:
                    first_chunk = False
                    lower_chunk = chunk[:64].lower()
                    if (
                        b"<!doctype" in lower_chunk
                        or b"<html" in lower_chunk
                    ):
                        return (
                            False,
                            "Downloaded payload appears to be an HTML page, not a Debian archive",
                        )

                sha256_hasher.update(chunk)
                total_bytes += len(chunk)

            if expected_size is not None and total_bytes != expected_size:
                return (
                    False,
                    f"Size mismatch: downloaded {total_bytes} bytes, expected {expected_size} bytes",
                )

            computed_sha256 = sha256_hasher.hexdigest().lower()
            if expected_sha256:
                clean_expected = (
                    expected_sha256.split(":", 1)[1]
                    if expected_sha256.startswith("sha256:")
                    else expected_sha256
                ).lower()
                if computed_sha256 != clean_expected:
                    return (
                        False,
                        f"SHA-256 mismatch: computed {computed_sha256}, expected {clean_expected}",
                    )

            return True, "Payload verified successfully"

    except urllib.error.HTTPError as e:
        return False, f"HTTP Error {e.code}: {e.reason}"
    except Exception as e:
        return False, f"Network error during download verification: {e}"


def generate_ebuild_content(
    base_version: str,
    archive_name: str,
    target_url: str,
) -> str:
    """Generate compliant EAPI 8 ebuild without dynamic global variables or lines > 80 chars."""
    content = f"""# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Which Browser? A browser selecting tool with rules to automate"
HOMEPAGE="https://which-browser-site.pages.dev"
SRC_URI="
\t{target_url}
"
S="${{WORKDIR}}"

LICENSE="All-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-util/patchelf"
RDEPEND="|| ( dev-libs/libayatana-appindicator )"
RESTRICT="mirror"

inherit unpacker xdg

QA_PREBUILT="usr/share/which_browser/*"

src_prepare() {{
\tdefault
\tchmod +w usr/share/which_browser/lib/libtray_manager_plugin.so || die
\tpatchelf --replace-needed libappindicator3.so.1 \\
\t\tlibayatana-appindicator3.so.1 \\
\t\tusr/share/which_browser/lib/libtray_manager_plugin.so || die
}}

src_unpack() {{
\tunpack_deb "{archive_name}"
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
\t\tsed -i -e '/^Version=/d' \\
\t\t\t"${{D}}/usr/share/applications/which_browser.desktop" || die
\tfi

\t# Ensure the icon file has the correct permissions
\tlocal icon_dir="${{D}}/usr/share/icons/hicolor/256x256/apps"
\tif [[ -f "${{icon_dir}}/which_browser.png" ]]; then
\t\tfperms 0644 /usr/share/icons/hicolor/256x256/apps/which_browser.png
\tfi
}}

pkg_postinst() {{
\txdg_pkg_postinst
\teinfo "Which Browser? has been installed."
\teinfo "Please set Which Browser? as the default HTTP and HTTPS handler."
}}

pkg_postrm() {{
\txdg_pkg_postrm
}}
"""
    return content


def apply_update(
    work_dir: Path,
    candidate: dict[str, Any],
    target_url: str,
    dry_run: bool = False,
) -> None:
    """Generate ebuild and upsert Manifest with transactional rollback on failure."""
    version = candidate["gentoo_version"]
    filename = candidate["filename"]
    base_version = candidate["base_version"]

    ebuild_path = work_dir / f"which_browser-{version}.ebuild"
    manifest_path = work_dir / "Manifest"
    manifest_backup: Path | None = None

    if dry_run:
        logging.info(
            f"[Dry-run] Would generate {ebuild_path} and update Manifest from {target_url}"
        )
        return

    work_dir.mkdir(parents=True, exist_ok=True)
    if manifest_path.exists():
        manifest_backup = work_dir / "Manifest.bak"
        shutil.copy2(manifest_path, manifest_backup)

    try:
        ebuild_content = generate_ebuild_content(
            base_version=base_version,
            archive_name=filename,
            target_url=target_url,
        )
        ebuild_path.write_text(ebuild_content, encoding="utf-8")
        logging.info(f"Written ebuild: {ebuild_path}")

        # Update Manifest via g2
        cmd = [
            "g2",
            "manifest",
            "upsert-from-url",
            target_url,
            filename,
            str(manifest_path),
        ]
        run_cmd(cmd)

        if not manifest_path.exists() or filename not in manifest_path.read_text(
            encoding="utf-8"
        ):
            raise RuntimeError(
                f"Manifest generation completed but {filename} was not found in Manifest."
            )

        if manifest_backup and manifest_backup.exists():
            manifest_backup.unlink()

        logging.info(
            f"Successfully updated which_browser to version {version} ({candidate['tag']})"
        )

    except Exception as e:
        logging.error(
            f"Failed to apply update for {version}, rolling back: {e}"
        )
        if ebuild_path.exists():
            ebuild_path.unlink()
        if manifest_backup and manifest_backup.exists():
            shutil.move(str(manifest_backup), str(manifest_path))
        raise


def set_github_output(outputs: dict[str, str]) -> None:
    """Write outputs to GITHUB_OUTPUT environment file if present."""
    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        with open(output_path, "a", encoding="utf-8") as f:
            for k, v in outputs.items():
                f.write(f"{k}={v}\n")
    for k, v in outputs.items():
        logging.info(f"Output: {k}={v}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Update which_browser Gentoo package from GitHub releases."
    )
    parser.add_argument(
        "--owner", default="arran4", help="Upstream GitHub repository owner"
    )
    parser.add_argument(
        "--repo", default="which_browser", help="Upstream GitHub repository name"
    )
    parser.add_argument(
        "--work-dir",
        type=Path,
        default=DEFAULT_WORK_DIR,
        help="Path to www-misc/which_browser directory",
    )
    parser.add_argument(
        "--base-download-url",
        default=DEFAULT_BASE_DOWNLOAD_URL,
        help="Base URL for public unauthenticated downloads",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Perform discovery and verification without modifying repository files",
    )
    parser.add_argument(
        "--token",
        default=None,
        help="GitHub token for authenticated API discovery",
    )

    args = parser.parse_args(argv)

    try:
        releases = get_github_releases(
            owner=args.owner, repo=args.repo, token=args.token
        )
    except Exception as e:
        logging.error(f"Cannot discover releases from upstream: {e}")
        return 1

    candidates = extract_candidates(releases)
    if not candidates:
        logging.info("No eligible which_browser release candidates discovered.")
        return 0

    latest = candidates[0]
    tag = latest["tag"]
    version = latest["gentoo_version"]
    filename = latest["filename"]
    base_version = latest["base_version"]
    logging.info(
        f"Latest eligible upstream release: {tag} (Gentoo PV: {version}, Asset: {filename})"
    )

    if check_ebuild_exists(args.work_dir, version):
        logging.info(
            f"Ebuild for which_browser-{version} already exists. Nothing to do."
        )
        return 0

    if check_pr_exists(tag, version):
        logging.info(
            f"Open Pull Request already exists for release {tag}. Nothing to do."
        )
        return 0

    target_url = (
        f"{args.base_download_url.rstrip('/')}/v{base_version}/{filename}"
    )
    expected_size = latest["asset"].get("size")
    expected_digest = latest["asset"].get("digest")

    download_ok, download_reason = verify_download(
        target_url=target_url,
        expected_size=expected_size,
        expected_sha256=expected_digest,
    )

    if not download_ok:
        logging.error(
            f"Public unauthenticated download verification failed for {target_url}: {download_reason}"
        )
        logging.error(
            "Refusing to generate ebuild or open Pull Request for unverified or broken public URL."
        )
        return 1

    try:
        apply_update(
            work_dir=args.work_dir,
            candidate=latest,
            target_url=target_url,
            dry_run=args.dry_run,
        )
    except Exception as e:
        logging.error(f"Failed to generate ebuild and Manifest: {e}")
        return 1

    set_github_output(
        {
            "generated_version": version,
            "generated_tag": tag,
            "archive_name": filename,
            "target_url": target_url,
        }
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
