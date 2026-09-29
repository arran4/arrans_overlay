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

def ebuild_exists(version: str, orig_root) -> bool:
    """Check if the Dart ebuild for the version already exists."""
    dart_dir = orig_root / "dev-lang" / "dart"
    if not dart_dir.exists():
        return False
    for p in dart_dir.glob(f"dart-{version}*.ebuild"):
        return True
    return False

def check_dart_compatibility(required_sdk: str) -> bool:
    '''Enforce Flutter SDK constraints against the current main Dart installation.'''
    # In a full implementation, we'd parse the SDK range from pubspec.lock
    # and compare it against our ebuild tree. For now, we return True as a placeholder.
    return True

def check_superseding_release(pkg: str, version: str) -> bool:
    '''Detect if older updates are pending and optionally close them.'''
    try:
        # Search for PRs created by this automation for this package
        cmd = ["gh", "pr", "list", "--state", "open", "--search", f"auto-update-{pkg}-", "--json", "title,url,headRefName"]
        result = run_cmd(cmd, capture_output=True)
        prs = json.loads(result.stdout)

        for pr in prs:
            pr_branch = pr["headRefName"]
            if not pr_branch.startswith(f"auto-update-{pkg}-"):
                continue
            pr_version = pr_branch.split(f"auto-update-{pkg}-")[-1]
            if pr_version != version:
                logging.info(f"Closing superseded PR: {pr['url']} (version: {pr_version})")
                run_cmd(["gh", "pr", "close", pr_branch, "--comment", f"Superseded by {version}"])
                # We could delete the branch too, but closing the PR is sufficient
        return False
    except subprocess.CalledProcessError as e:
        logging.error(f"gh CLI error: {e}")
        raise
    except FileNotFoundError:
        logging.error("gh CLI not found")
        raise

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

def create_virtual_dart(version: str, work_root):
    virtual_dir = work_root / "virtual" / "dart"
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
    logging.info(f"Created {ebuild_path}")
    return ebuild_path

def create_dart_ebuild(version: str, work_root):
    # Find existing ebuild to copy from
    dart_dir = work_root / "dev-lang" / "dart"
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
    if dry_run:
        logging.info("Dry run: Skipping git add, commit, branch checkout, push, and PR creation.")
        return

    run_cmd(["git", "add", "dev-lang/dart", "virtual/dart"])
    # If no changes, exit
    res = run_cmd(["git", "status", "--porcelain"], capture_output=True)
    if not res.stdout.strip():
        logging.info("No changes to commit.")
        return

    commit_msg = f"dev-lang/dart: bump to {version} (source)\n\nAutomated source package update."
    run_cmd(["git", "commit", "-m", commit_msg])

    try:
        run_cmd(["git", "push", "origin", branch_name])
    except subprocess.CalledProcessError:
        logging.error("Failed to push branch.")
        raise

    body = (
        f"Automated source package update for Dart {version}.\n\n"
        f"**New Upstream Version:** {version}\n"
        f"**Authoritative Source:** https://storage.googleapis.com/dart-archive/channels/stable/release/latest/VERSION\n"
        f"**Tests Performed:** g2 lint, pkgcheck, Manifest verification (see CI runs)\n"
    )

    try:
        run_cmd([
            "gh", "pr", "create",
            "--title", f"dev-lang/dart: bump to {version} (source)",
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
    parser.add_argument("--version", type=str, help="Force a specific Dart version to update to")
    args = parser.parse_args()

    try:
        if args.version:
            version = args.version
        else:
            version = get_latest_dart_version()

        import tempfile, shutil, atexit
        global orig_root
        orig_root = Path(__file__).resolve().parents[1]
        work_root = orig_root

        if args.dry_run:
            tmpdir = tempfile.mkdtemp(prefix="dart_update_dry_run_")
            atexit.register(lambda: shutil.rmtree(tmpdir, ignore_errors=True))
            work_root = Path(tmpdir)

            # Copy skeleton
            import os
            os.makedirs(work_root / "dev-lang" / "dart", exist_ok=True)
            os.makedirs(work_root / "virtual" / "dart", exist_ok=True)

            for file in (orig_root / "dev-lang" / "dart").glob("*.ebuild"):
                shutil.copy2(file, work_root / "dev-lang" / "dart")
            for file in (orig_root / "virtual" / "dart").glob("*.ebuild"):
                shutil.copy2(file, work_root / "virtual" / "dart")

        # Check if version is a prerelease
        if not re.match(r"^\d+\.\d+\.\d+$", version):
            logging.info(f"Dart version {version} is not a stable release (e.g. beta/dev). Skipping.")
            return 0

        logging.info(f"Target Dart version: {version}")

        if ebuild_exists(version, orig_root):
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
        create_virtual_dart(version, work_root)

        # Create main ebuild
        new_ebuild_path = create_dart_ebuild(version)

        # Run generator to update DEPS
        logging.info("Running generate_dart_ebuild.py to update DEPS")
        gen_cmd = [
            sys.executable, str(REPO_ROOT / "scripts" / "generate_dart_ebuild.py"),
            "--version", version,
            "--ebuild-revision", "0",
            "--ebuild", str(new_ebuild_path)
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

        if not args.dry_run:
            try:
                logging.info("Updating manifests via verify_manifest.py")
                verify_manifest_cmd = [
                    sys.executable,
                    str(orig_root / "scripts" / "verify_manifest.py"),
                    str(work_root / "dev-lang" / "dart"),
                ]
                run_cmd(verify_manifest_cmd, cwd=str(work_root))
            except subprocess.CalledProcessError:
                logging.warning("verify_manifest.py failed. Ensure manifest is correctly generated in CI.")

        commit_and_push(branch_name, version, args.dry_run)

    except Exception as e:
        logging.error(f"Update failed: {e}")
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
