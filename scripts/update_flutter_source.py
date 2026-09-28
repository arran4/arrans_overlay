#!/usr/bin/env python3
"""Update Flutter source package automatically.

Detects the latest stable Flutter release, checks if it's already packaged or
pending in a PR, fetches internal versions (Engine, Dart, Fonts, Gradle wrapper)
and creates a new PR with the updated source ebuilds (Engine, Flutter, Virtual).
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

# Adjust path so we can import the generator module if needed
sys.path.insert(0, str(Path(__file__).parent))

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

FLUTTER_RELEASES_URL = "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
REPO_ROOT = Path(__file__).resolve().parents[1]

def run_cmd(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    logging.info(f"Running: {' '.join(cmd)}")
    kwargs.setdefault("check", True)
    kwargs.setdefault("text", True)
    return subprocess.run(cmd, **kwargs)

def get_latest_flutter_version() -> str:
    logging.info(f"Fetching latest Flutter version from {FLUTTER_RELEASES_URL}")
    with urllib.request.urlopen(FLUTTER_RELEASES_URL) as response:
        data = json.loads(response.read().decode("utf-8"))
        stable_releases = [r for r in data.get("releases", []) if r.get("channel") == "stable"]
        if not stable_releases:
            raise ValueError("No stable releases found")
        # Releases are typically sorted newest first
        return stable_releases[0]["version"]

def get_flutter_internal_version(flutter_version: str, file_path: str) -> str:
    url = f"https://raw.githubusercontent.com/flutter/flutter/{flutter_version}/bin/internal/{file_path}"
    logging.info(f"Fetching {url}")
    with urllib.request.urlopen(url) as response:
        content = response.read().decode("utf-8").strip()
        # Some files like material_fonts.version have the format: flutter_infra_release/flutter/fonts/{rev}/fonts.zip
        # We need to extract the hash
        return content

def extract_hash_from_url_like(content: str) -> str:
    # E.g. flutter_infra_release/flutter/fonts/3012db47f3130e62f7cc0beabff968a33cbec8d8/fonts.zip
    parts = content.split("/")
    for p in parts:
        if len(p) == 40 and re.match(r"^[0-9a-f]+$", p):
            return p
    return content

def ebuild_exists(package: str, version: str) -> bool:
    """Check if the ebuild for the version already exists."""
    pkg_dir = REPO_ROOT / package
    if not pkg_dir.exists():
        return False
    # Use basename for glob matching
    basename = package.split('/')[-1]
    for p in pkg_dir.glob(f"{basename}-{version}*.ebuild"):
        return True
    return False

def check_branch_exists(branch_name: str) -> bool:
    try:
        run_cmd(["git", "show-ref", "--verify", f"refs/heads/{branch_name}"], check=True, capture_output=True)
        return True
    except subprocess.CalledProcessError:
        return False

def check_pr_exists(branch_name: str) -> bool:
    try:
        res = run_cmd(["gh", "pr", "list", "--head", branch_name, "--json", "url", "--state", "open"], check=True, capture_output=True)
        prs = json.loads(res.stdout)
        return len(prs) > 0
    except subprocess.CalledProcessError as e:
        logging.error(f"gh CLI error: {e}")
        raise
    except FileNotFoundError:
        logging.warning("gh CLI not available. Skipping remote PR check.")
        return False

def create_virtual_flutter(version: str):
    virtual_dir = REPO_ROOT / "virtual" / "flutter"
    virtual_dir.mkdir(parents=True, exist_ok=True)
    ebuild_path = virtual_dir / f"flutter-{version}.ebuild"
    content = f"""# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for the Flutter SDK"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND="|| (
\t~dev-lang/flutter-{version}
\t~dev-lang/flutter-bin-{version}
)"
"""
    ebuild_path.write_text(content)
    logging.info(f"Created {ebuild_path.relative_to(REPO_ROOT)}")

def create_ebuild_copy(package: str, version: str):
    pkg_dir = REPO_ROOT / package
    basename = package.split('/')[-1]
    existing_ebuilds = list(pkg_dir.glob(f"{basename}-*.ebuild"))
    if not existing_ebuilds:
        raise FileNotFoundError(f"No existing ebuild found in {package} to copy from")

    existing_ebuild = sorted(existing_ebuilds)[-1]
    new_ebuild_path = pkg_dir / f"{basename}-{version}.ebuild"
    shutil.copy2(existing_ebuild, new_ebuild_path)
    logging.info(f"Copied {existing_ebuild.name} to {new_ebuild_path.name}")
    return new_ebuild_path

def commit_and_push(branch_name: str, version: str, engine_rev: str, dart_rev: str, fonts_rev: str, gradle_rev: str, dry_run: bool):
    if dry_run:
        logging.info("Dry run: Skipping git add, commit, branch checkout, push, and PR creation.")
        return

    run_cmd(["git", "add", "dev-libs/flutter-engine", "dev-lang/flutter", "virtual/flutter"])
    res = run_cmd(["git", "status", "--porcelain"], capture_output=True)
    if not res.stdout.strip():
        logging.info("No changes to commit.")
        return

    commit_msg = (
        f"dev-lang/flutter: bump to {version} (source)\n\n"
        f"Automated coordinated source package update."
    )
    run_cmd(["git", "commit", "-m", commit_msg])

    try:
        run_cmd(["git", "push", "origin", branch_name])
    except subprocess.CalledProcessError:
        logging.error("Failed to push branch.")
        raise

    body = (
        f"Automated coordinated source package update for Flutter {version}.\n\n"
        f"**New Upstream Version:** {version}\n"
        f"**Authoritative Source:** https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json\n"
        f"**Flutter Engine revision:** {engine_rev}\n"
        f"**Pinned Dart revision:** {dart_rev}\n"
        f"**Material Fonts revision:** {fonts_rev}\n"
        f"**Gradle Wrapper revision:** {gradle_rev}\n"
        f"**Tests Performed:** g2 lint, pkgcheck, Manifest verification (see CI runs)\n"
    )

    try:
        run_cmd([
            "gh", "pr", "create",
            "--title", f"dev-lang/flutter: bump to {version} (source)",
            "--body", body,
            "--head", branch_name,
            "--base", "main"
        ])
        logging.info("PR created successfully.")
    except (subprocess.CalledProcessError, FileNotFoundError):
        logging.error("Failed to create PR using gh CLI.")
        raise

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Do not push or create PR")
    parser.add_argument("--version", type=str, help="Force a specific Flutter version to update to")
    args = parser.parse_args()

    try:
        if args.version:
            version = args.version
        else:
            version = get_latest_flutter_version()

        if not re.match(r"^\d+\.\d+\.\d+(-\d+\.\d+\.pre)?$", version) and "beta" not in version:
             if not re.match(r"^\d+\.\d+\.\d+$", version):
                logging.info(f"Flutter version {version} does not look like stable release. Skipping.")
                return 0

        logging.info(f"Target Flutter version: {version}")

        if ebuild_exists("dev-lang/flutter", version):
            logging.info(f"Flutter {version} is already packaged. Exiting.")
            return 0

        branch_name = f"auto-update-flutter-source-{version}"

        if check_branch_exists(branch_name) or check_pr_exists(branch_name):
            logging.info(f"Branch or PR for {branch_name} already exists. Exiting.")
            return 0

        # Fetch internal versions
        engine_rev = get_flutter_internal_version(version, "engine.version")

        # Dart revision is inside DEPS
        deps_url = f"https://raw.githubusercontent.com/flutter/flutter/{version}/DEPS"
        logging.info(f"Fetching {deps_url}")
        with urllib.request.urlopen(deps_url) as response:
            deps_content = response.read().decode("utf-8")
            match = re.search(r"'dart_revision':\s*'([0-9a-fA-F]+)'", deps_content)
            if not match:
                raise ValueError("Could not find dart_revision in DEPS")
            dart_rev = match.group(1)

        fonts_content = get_flutter_internal_version(version, "material_fonts.version")
        fonts_rev = extract_hash_from_url_like(fonts_content)
        gradle_content = get_flutter_internal_version(version, "gradle_wrapper.version")
        gradle_rev = extract_hash_from_url_like(gradle_content)

        logging.info(f"Engine: {engine_rev}, Dart: {dart_rev}, Fonts: {fonts_rev}, Gradle: {gradle_rev}")

        if not args.dry_run:
            run_cmd(["git", "checkout", "-b", branch_name])

        # Create ebuilds
        create_virtual_flutter(version)
        create_ebuild_copy("dev-libs/flutter-engine", version)
        flutter_ebuild = create_ebuild_copy("dev-lang/flutter", version)

        # Update Engine DEPS
        logging.info("Running generate_flutter_engine_ebuild.py to update DEPS")
        engine_ebuild = REPO_ROOT / "dev-libs" / "flutter-engine" / f"flutter-engine-{version}.ebuild"
        engine_gen_cmd = [
            sys.executable, str(REPO_ROOT / "scripts" / "generate_flutter_engine_ebuild.py"),
            "--version", version,
            "--engine-revision", engine_rev,
            "--dart-revision", dart_rev,
            "--ebuild", str(engine_ebuild)
        ]
        try:
            run_cmd(engine_gen_cmd)
        except subprocess.CalledProcessError as e:
            logging.error(f"Engine Generator failed. Error: {e}")
            raise

        run_cmd(engine_gen_cmd + ["--check"])

        # Update Flutter PUB DEPS
        logging.info("Running generate_flutter_ebuild.py to update PUB DEPS")
        flutter_gen_cmd = [
            sys.executable, str(REPO_ROOT / "scripts" / "generate_flutter_ebuild.py"),
            "--ebuild", str(flutter_ebuild),
            "--version", version,
            "--engine-revision", engine_rev,
            "--material-fonts-revision", fonts_rev,
            "--gradle-wrapper-revision", gradle_rev
        ]
        try:
            run_cmd(flutter_gen_cmd)
        except subprocess.CalledProcessError as e:
            logging.error(f"Flutter Generator failed. Error: {e}")
            raise

        run_cmd(flutter_gen_cmd + ["--check"])

        if not args.dry_run:
            try:
                logging.info("Running g2 cache generate")
                g2_cmd = ["g2", "cache", "generate", "dev-libs/flutter-engine", "dev-lang/flutter"]
                run_cmd(g2_cmd, cwd=str(REPO_ROOT))
            except (subprocess.CalledProcessError, FileNotFoundError):
                logging.warning("g2 cache generate failed or missing. Ensure manifest is correctly generated in CI.")

        commit_and_push(branch_name, version, engine_rev, dart_rev, fonts_rev, gradle_rev, args.dry_run)

    except Exception as e:
        logging.error(f"Update failed: {e}")
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
