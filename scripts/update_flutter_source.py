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

def parse_gentoo_version(version: str):
    import re
    match = re.match(r'^(\d+(?:\.\d+)*)(?:-r(\d+))?$', version)
    if not match: return ([0], 0)
    return ([int(x) for x in match.group(1).split('.')], int(match.group(2)) if match.group(2) else 0)

def compare_versions(v1: str, v2: str) -> int:
    p1 = parse_gentoo_version(v1)
    p2 = parse_gentoo_version(v2)
    if p1[0] > p2[0]: return 1
    if p1[0] < p2[0]: return -1
    if p1[1] > p2[1]: return 1
    if p1[1] < p2[1]: return -1
    return 0


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
    global orig_root
    orig_root = Path(__file__).resolve().parents[1]
    pkg_dir = orig_root / package
    if not pkg_dir.exists():
        return False
    # Use basename for glob matching
    basename = package.split('/')[-1]
    import re
    for p in pkg_dir.glob(f"{basename}-*.ebuild"):
        m = re.match(r'^' + basename + r'-(.*)\.ebuild$', p.name)
        if m:
            v_ver, _ = parse_gentoo_version(m.group(1))
            t_ver, _ = parse_gentoo_version(version)
            if v_ver == t_ver:
                return True
    return False

def check_dart_compatibility(version: str) -> str:
    '''Extracts the Dart SDK constraint from the Flutter pubspec.yaml.'''
    import urllib.request, re
    url = f"https://raw.githubusercontent.com/flutter/flutter/{version}/packages/flutter_tools/pubspec.yaml"
    try:
        with urllib.request.urlopen(url) as response:
            yaml_content = response.read().decode('utf-8')
            env_match = re.search(r'^environment:\s*\n(.*?)(?:^\S|\Z)', yaml_content, re.MULTILINE | re.DOTALL)
            if env_match:
                sdk_match = re.search(r'^\s*sdk:\s*"?\'?([^"\'\n#]+)"?\'?', env_match.group(1), re.MULTILINE)
                if sdk_match:
                    constraint = sdk_match.group(1).strip()
                    if constraint.startswith('^'):
                        return constraint[1:]
                    return constraint.replace('>=', '').split('<')[0].strip()
    except Exception as e:
        import logging
        logging.error(f"Failed to fetch pubspec.yaml for dart compatibility: {e}")
    raise ValueError(f"Could not determine Dart SDK constraint for Flutter {version}")

def check_superseding_release(pkg: str, version: str) -> bool:
    '''Detect if older updates are pending.'''
    try:
        cmd = ["gh", "pr", "list", "--state", "open", "--search", f"auto-update-{pkg}-", "--json", "title,url,headRefName"]
        result = run_cmd(cmd, capture_output=True)
        import json
        prs = json.loads(result.stdout)

        for pr in prs:
            pr_branch = pr["headRefName"]
            if not pr_branch.startswith(f"auto-update-{pkg}-"):
                continue
            pr_version = pr_branch.split(f"auto-update-{pkg}-")[-1]
            if compare_versions(pr_version, version) == -1:
                logging.info(f"Found older PR: {pr['url']} (version: {pr_version}) that will be superseded.")
            elif compare_versions(pr_version, version) == 1:
                logging.info(f"Found newer PR: {pr['url']} (version: {pr_version}). This run is superseded.")
                return True
        return False
    except subprocess.CalledProcessError as e:
        logging.error(f"gh CLI error: {e}")
        raise
    except FileNotFoundError:
        logging.error("gh CLI not found")
        raise

def close_superseding_releases(pkg: str, version: str):
    '''Close older updates.'''
    try:
        cmd = ["gh", "pr", "list", "--state", "open", "--search", f"auto-update-{pkg}-", "--json", "title,url,headRefName"]
        result = run_cmd(cmd, capture_output=True)
        import json
        prs = json.loads(result.stdout)

        for pr in prs:
            pr_branch = pr["headRefName"]
            if not pr_branch.startswith(f"auto-update-{pkg}-"):
                continue
            pr_version = pr_branch.split(f"auto-update-{pkg}-")[-1]
            if pr_version != version:
                logging.info(f"Closing superseded PR: {pr['url']} (version: {pr_version})")
                run_cmd(["gh", "pr", "close", pr_branch, "--comment", f"Superseded by {version}"])
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
        logging.error("gh CLI not available. Failing closed.")
        import sys
        sys.exit(1)

def create_virtual_flutter(version: str, work_root):
    virtual_dir = work_root / "virtual" / "flutter"
    virtual_dir.mkdir(parents=True, exist_ok=True)
    ebuild_path = virtual_dir / f"flutter-{version}.ebuild"
    if ebuild_path.exists():
        logging.info(f"Virtual {ebuild_path.name} already exists. Leaving it intact.")
        return

    existing_virtuals = list(virtual_dir.glob("*.ebuild"))
    if not existing_virtuals:
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
        logging.info(f"Created {ebuild_path} from scratch")
        return

    def sort_key(p):
        m = re.match(r'^flutter-(.*)\.ebuild$', p.name)
        if m: return parse_gentoo_version(m.group(1))
        return ([0], 0)

    latest_virtual = sorted(existing_virtuals, key=sort_key)[-1]
    v_content = latest_virtual.read_text()

    m = re.match(r'^flutter-(.*)\.ebuild$', latest_virtual.name)
    old_ver = m.group(1) if m else version

    new_content = re.sub(r'~dev-lang/flutter-[0-9\.\-r]+', f'~dev-lang/flutter-{version}', v_content)
    new_content = re.sub(r'~dev-lang/flutter-bin-[0-9\.\-r]+', f'>=dev-lang/flutter-bin-{old_ver}', new_content)

    ebuild_path.write_text(new_content)
    logging.info(f"Created {ebuild_path} by copying {latest_virtual.name}")

def create_ebuild_copy(package: str, version: str, work_root):
    pkg_dir = work_root / package
    basename = package.split('/')[-1]
    existing_ebuilds = list(pkg_dir.glob(f"{basename}-*.ebuild"))
    if not existing_ebuilds:
        raise FileNotFoundError(f"No existing ebuild found in {package} to copy from")

    def sort_key(ebuild_path):
        import re
        m = re.match(r'^' + basename + r'-(.*)\.ebuild$', ebuild_path.name)
        if m:
            return parse_gentoo_version(m.group(1))
        return ([0], 0)

    existing_ebuild = sorted(existing_ebuilds, key=sort_key)[-1]
    new_ebuild_path = pkg_dir / f"{basename}-{version}.ebuild"
    shutil.copy2(existing_ebuild, new_ebuild_path)
    logging.info(f"Copied {existing_ebuild.name} to {new_ebuild_path.name}")
    return new_ebuild_path

def commit_and_push(branch_name: str, version: str, engine_rev: str, dart_rev: str, fonts_rev: str, gradle_rev: str, compat_msg: str, dry_run: bool):
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
        f"**Host Dart constraint:** {compat_msg}\n"
        f"**Material Fonts revision:** {fonts_rev}\n"
        f"**Gradle Wrapper revision:** {gradle_rev}\n"
        f"**Manifest Generation:** Completed successfully.\n"
        f"**Dependency/exclusion review result:** Needs human review (fail-closed generator policy active).\n"
        f"**Patch refresh/review result:** Needs human review if build fails.\n"
        f"**Tests Performed:** Pending CI runs for g2 lint, pkgcheck, and integration verification.\n\n"
        f"Related to #939\n"
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
        close_superseding_releases("flutter-source", version)
    except (subprocess.CalledProcessError, FileNotFoundError):
        logging.error("Failed to create PR using gh CLI.")
        raise

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Do not push or create PR")
    parser.add_argument("--ref", type=str, help="Force a specific upstream git ref/hash")
    parser.add_argument("--version", type=str, help="Force a specific Flutter version to update to")
    args = parser.parse_args()

    try:
        if args.version:
            version = args.version
        else:
            version = get_latest_flutter_version()

        import tempfile, shutil, atexit
        global orig_root
        orig_root = Path(__file__).resolve().parents[1]
        work_root = orig_root

        if args.dry_run:
            tmpdir = tempfile.mkdtemp(prefix="flutter_update_dry_run_")
            atexit.register(lambda: shutil.rmtree(tmpdir, ignore_errors=True))
            work_root = Path(tmpdir)

            # Copy skeleton
            import os
            os.makedirs(work_root / "dev-libs" / "flutter-engine", exist_ok=True)
            os.makedirs(work_root / "dev-lang" / "flutter", exist_ok=True)
            os.makedirs(work_root / "virtual" / "flutter", exist_ok=True)

            for file in (orig_root / "dev-libs" / "flutter-engine").glob("*.ebuild"):
                shutil.copy2(file, work_root / "dev-libs" / "flutter-engine")
            for file in (orig_root / "dev-lang" / "flutter").glob("*.ebuild"):
                shutil.copy2(file, work_root / "dev-lang" / "flutter")
            for file in (orig_root / "virtual" / "flutter").glob("*.ebuild"):
                shutil.copy2(file, work_root / "virtual" / "flutter")

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

        required_dart_range = check_dart_compatibility(version)
        compat_msg = f"Requires Dart host SDK range: >={required_dart_range} (Engine pinned to: {dart_rev})"

        if required_dart_range != "0.0.0":
            dart_dir = orig_root / "dev-lang" / "dart"

            found_compatible = False
            for p in dart_dir.glob("dart-*.ebuild"):
                m = re.match(r'^dart-(.*)\.ebuild$', p.name)
                if m:
                    if compare_versions(m.group(1), required_dart_range) >= 0:
                        found_compatible = True
                        break

            if not found_compatible:
                logging.error(f"Host Dart SDK requirement >= {required_dart_range} not satisfied locally.")
                dart_branch_name = f"auto-update-dart-source-{required_dart_range.split('-')[0]}"
                compat_msg += f" -- ERROR: Host Dart version >= {required_dart_range} not found. Must merge Dart PR {dart_branch_name} first."
                logging.error(f"Must generate Dart update first for {required_dart_range}.")
                sys.exit(1)

        if not args.dry_run:
            run_cmd(["git", "checkout", "-b", branch_name])

        # Create ebuilds
        create_virtual_flutter(version, work_root)
        create_ebuild_copy("dev-libs/flutter-engine", version, work_root)
        flutter_ebuild = create_ebuild_copy("dev-lang/flutter", version, work_root)

        # Update Engine DEPS
        logging.info("Running generate_flutter_engine_ebuild.py to update DEPS")
        engine_ebuild = work_root / "dev-libs" / "flutter-engine" / f"flutter-engine-{version}.ebuild"
        engine_gen_cmd = [
            sys.executable, str(orig_root / "scripts" / "generate_flutter_engine_ebuild.py"),
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
        compat_msg = f"Requires Dart source revision: {dart_rev}"
        flutter_gen_cmd = [
            sys.executable, str(orig_root / "scripts" / "generate_flutter_ebuild.py"),
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
                logging.info("Updating manifests via verify_manifest.py")
                verify_manifest_cmd = [
                    sys.executable,
                    str(orig_root / "scripts" / "verify_manifest.py"),
                    str(work_root / "dev-libs" / "flutter-engine"),
                    str(work_root / "dev-lang" / "flutter"),
                ]
                run_cmd(verify_manifest_cmd, cwd=str(work_root))
            except subprocess.CalledProcessError:
                logging.error("verify_manifest.py failed. Failing.")
                sys.exit(1)

        commit_and_push(branch_name, version, engine_rev, dart_rev, fonts_rev, gradle_rev, compat_msg, args.dry_run)

    except Exception as e:
        logging.error(f"Update failed: {e}")
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
