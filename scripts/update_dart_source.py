#!/usr/bin/env python3
"""Update Dart source package automatically.

Detects the latest stable Dart release, checks if it's already packaged or
pending in a PR, and if not, creates a new PR with the updated source ebuild
and virtual package.
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
import tempfile
import urllib.request
from pathlib import Path

# Adjust path so we can import the generator module if needed
sys.path.insert(0, str(Path(__file__).parent))

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

DART_VERSION_URL = "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION"
REPO_ROOT = Path(__file__).resolve().parents[1]

def run_cmd(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    logging.info(f"Running: {' '.join(cmd)}")
    kwargs.setdefault("check", True)
    kwargs.setdefault("text", True)
    return subprocess.run(cmd, **kwargs)

def get_latest_dart_version() -> str:
    logging.info(f"Fetching latest Dart version from {DART_VERSION_URL}")
    with urllib.request.urlopen(DART_VERSION_URL) as response:
        data = json.loads(response.read().decode("utf-8"))
        version = data.get("version")
        if not version:
            raise ValueError("Failed to parse version from Dart VERSION file")
        return version

def ebuild_exists(version: str) -> bool:
    """Check if the Dart ebuild for the version already exists."""
    dart_dir = REPO_ROOT / "dev-lang" / "dart"
    if not dart_dir.exists():
        return False
    for p in dart_dir.glob(f"dart-{version}*.ebuild"):
        return True
    return False

def check_branch_exists(branch_name: str) -> bool:
    try:
        run_cmd(["git", "show-ref", "--verify", f"refs/heads/{branch_name}"], check=True, capture_output=True)
        return True
    except subprocess.CalledProcessError:
        return False

def check_pr_exists(branch_name: str) -> bool:
    # If gh cli is available, we check if PR exists
    try:
        res = run_cmd(["gh", "pr", "list", "--head", branch_name, "--json", "url"], check=True, capture_output=True)
        prs = json.loads(res.stdout)
        return len(prs) > 0
    except (subprocess.CalledProcessError, FileNotFoundError):
        logging.warning("gh CLI not available or failed. Assuming PR check based on branch presence only.")
        return False

def create_virtual_dart(version: str):
    virtual_dir = REPO_ROOT / "virtual" / "dart"
    virtual_dir.mkdir(parents=True, exist_ok=True)
    ebuild_path = virtual_dir / f"dart-{version}.ebuild"
    content = f"""# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for the Dart SDK"

SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv"

RDEPEND="|| (
\t~dev-lang/dart-{version}
\t~dev-lang/dart-bin-{version}
)"
"""
    ebuild_path.write_text(content)
    logging.info(f"Created {ebuild_path.relative_to(REPO_ROOT)}")
    return ebuild_path

def create_dart_ebuild(version: str):
    # Find existing ebuild to copy from
    dart_dir = REPO_ROOT / "dev-lang" / "dart"
    existing_ebuilds = list(dart_dir.glob("dart-*.ebuild"))
    if not existing_ebuilds:
        raise FileNotFoundError("No existing Dart ebuild found to copy from")

    # Sort by version/revision to get the latest
    existing_ebuild = sorted(existing_ebuilds)[-1]

    new_ebuild_path = dart_dir / f"dart-{version}.ebuild"
    shutil.copy2(existing_ebuild, new_ebuild_path)
    logging.info(f"Copied {existing_ebuild.name} to {new_ebuild_path.name}")

    return new_ebuild_path

def commit_and_push(branch_name: str, version: str, dry_run: bool):
    run_cmd(["git", "add", "dev-lang/dart", "virtual/dart"])
    # If no changes, exit
    res = run_cmd(["git", "status", "--porcelain"], capture_output=True)
    if not res.stdout.strip():
        logging.info("No changes to commit.")
        return

    commit_msg = f"dev-lang/dart: bump to {version} (source)\n\nAutomated source package update."
    run_cmd(["git", "commit", "-m", commit_msg])

    if dry_run:
        logging.info(f"Dry run: Would push branch {branch_name} and create PR")
        return

    try:
        run_cmd(["git", "push", "origin", branch_name])
    except subprocess.CalledProcessError:
        logging.error("Failed to push branch. You might need to use a PAT or check permissions.")
        raise

    try:
        run_cmd([
            "gh", "pr", "create",
            "--title", f"dev-lang/dart: bump to {version} (source)",
            "--body", f"Automated source package update for Dart {version}.",
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
    parser.add_argument("--version", type=str, help="Force a specific Dart version to update to")
    args = parser.parse_args()

    try:
        if args.version:
            version = args.version
        else:
            version = get_latest_dart_version()

        # Check if version is a prerelease
        if not re.match(r"^\d+\.\d+\.\d+$", version):
            logging.info(f"Dart version {version} is not a stable release (e.g. beta/dev). Skipping.")
            return 0

        logging.info(f"Target Dart version: {version}")

        if ebuild_exists(version):
            logging.info(f"Dart {version} is already packaged. Exiting.")
            return 0

        branch_name = f"auto-update-dart-source-{version}"

        # In a real GH action, we might just be on detached HEAD, but locally we check branches
        if check_branch_exists(branch_name) or check_pr_exists(branch_name):
            logging.info(f"Branch or PR for {branch_name} already exists. Exiting.")
            return 0

        if not args.dry_run:
            run_cmd(["git", "checkout", "-b", branch_name])

        # Create virtual ebuild
        create_virtual_dart(version)

        # Create main ebuild
        new_ebuild_path = create_dart_ebuild(version)

        # Run generator to update DEPS
        logging.info("Running generate_dart_ebuild.py to update DEPS")
        gen_cmd = [
            sys.executable, str(REPO_ROOT / "scripts" / "generate_dart_ebuild.py"),
            "--version", version,
            "--revision", "0"
        ]
        # Run it but if it fails (e.g., new unreviewed deps), we fail closed
        try:
            run_cmd(gen_cmd)
        except subprocess.CalledProcessError as e:
            logging.error(f"Generator failed. Unreviewed DEPS changes? Error: {e}")
            raise

        # Check that it works via check mode
        try:
            run_cmd(gen_cmd + ["--check"])
        except subprocess.CalledProcessError as e:
            logging.error(f"Generator check mode failed. Error: {e}")
            raise

        # Manifest update (dummy for local sandbox, assumes g2 available in CI)
        # We try to use the manifest upsert-from-url approach if we can, otherwise manual
        try:
            logging.info("Running g2 manifest generation (requires g2 installed)")
            # g2 might not be installed, use go run if available
            g2_cmd = ["go", "run", "github.com/arran4/g2/cmd/g2@latest", "cache", "generate", "dev-lang/dart"]
            run_cmd(g2_cmd, cwd=str(REPO_ROOT))
        except (subprocess.CalledProcessError, FileNotFoundError):
            logging.warning("g2 cache generate failed or missing. Skipping manifest generation in this script.")
            # Depending on requirements we might need to actually download it or assume a GH action step does it.

        commit_and_push(branch_name, version, args.dry_run)

    except Exception as e:
        logging.error(f"Update failed: {e}")
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
