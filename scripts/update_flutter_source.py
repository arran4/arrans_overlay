#!/usr/bin/env python3
"""Update Flutter source package automatically.

Detects the latest stable Flutter release, checks if it's already packaged or
pending in a PR, fetches internal versions (Engine, Dart, Fonts, Gradle wrapper)
and creates a new PR with the updated source ebuilds (Engine, Flutter, Virtual).
"""

from __future__ import annotations
import sys

import argparse
import atexit
import json
import logging
import os
import re
import shutil
import subprocess
import tempfile
import urllib.request
from pathlib import Path

# Allow both direct execution and test imports from the repository root.
sys.path.insert(0, str(Path(__file__).parent))

from source_update_utils import (
    carry_forward_versioned_files,
    inherit_previous_patch_files,
)
from flutter_release_spec import FlutterReleaseSpec, SHA

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


logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

FLUTTER_RELEASES_URL = "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
REPO_ROOT = Path(__file__).resolve().parents[1]

def run_cmd(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    logging.info(f"Running: {' '.join(cmd)}")
    kwargs.setdefault("check", True)
    kwargs.setdefault("text", True)
    return subprocess.run(cmd, **kwargs)

def get_flutter_release(version: str = None) -> dict:
    logging.info(f"Fetching Flutter release metadata from {FLUTTER_RELEASES_URL}")
    with urllib.request.urlopen(FLUTTER_RELEASES_URL) as response:
        data = json.loads(response.read().decode("utf-8"))

        # In releases_linux.json, current_release tells us the exact hash of the current stable channel tip
        # OR we can search for the specific version in the array.

        releases = data.get("releases", [])
        if not version:
            # We want the authoritative tip of the stable channel.
            # data["current_release"]["stable"] contains the hash of the latest stable release.
            stable_hash = data.get("current_release", {}).get("stable")
            if not stable_hash:
                raise ValueError("No current stable release hash found in metadata")

            for r in releases:
                if r.get("hash") == stable_hash:
                    if r.get("channel") != "stable" or not r.get("version"):
                        raise ValueError("Current stable release object is incomplete or non-stable")
                    return r
            raise ValueError(f"Could not find release object for stable hash {stable_hash}")
        else:
            # Find the exact release for the given version
            for r in releases:
                if r.get("version") == version and r.get("channel") == "stable":
                    if not r.get("hash"):
                        raise ValueError(f"Stable release {version} is missing hash")
                    return r
            raise ValueError(f"Could not find stable release object for version {version}")

def get_latest_flutter_version() -> str:
    return get_flutter_release()["version"]

def get_flutter_internal_version(ref: str, file_path: str) -> str:
    url = f"https://raw.githubusercontent.com/flutter/flutter/{ref}/bin/internal/{file_path}"
    logging.info(f"Fetching {url}")
    with urllib.request.urlopen(url) as response:
        content = response.read().decode("utf-8").strip()
        # Some files like material_fonts.version have the format: flutter_infra_release/flutter/fonts/{rev}/fonts.zip
        # We need to extract the hash
        return content


def checked_sha(value: str, label: str) -> str:
    if not SHA.fullmatch(value):
        raise ValueError(f"invalid {label}: {value!r}")
    return value


def get_deps_dart_revision(ref: str, label: str) -> str:
    url = f"https://raw.githubusercontent.com/flutter/flutter/{ref}/DEPS"
    logging.info("Fetching %s", url)
    with urllib.request.urlopen(url) as response:
        content = response.read().decode("utf-8")
    match = re.search(r"'dart_revision':\s*'([0-9a-fA-F]+)'", content)
    if not match:
        raise ValueError(f"Could not find dart_revision in {label} DEPS")
    return checked_sha(match.group(1).lower(), f"{label} Dart revision")


def get_commit_timestamp(repo: str, commit_sha: str) -> str:
    """Fetch the ISO commit timestamp for a Git commit in repo."""
    try:
        proc = subprocess.run(
            ["git", "show", "-s", "--format=%cI", commit_sha],
            capture_output=True, text=True, check=False,
        )
        if proc.returncode == 0 and proc.stdout.strip():
            return proc.stdout.strip()
    except Exception:
        pass

    try:
        proc = subprocess.run(
            ["gh", "api", f"repos/{repo}/commits/{commit_sha}", "--jq", ".commit.committer.date"],
            capture_output=True, text=True, check=False,
        )
        if proc.returncode == 0 and proc.stdout.strip():
            return proc.stdout.strip()
    except Exception:
        pass

    url = f"https://api.github.com/repos/{repo}/commits/{commit_sha}"
    req = urllib.request.Request(url, headers={"User-Agent": "arrans_overlay_updater"})
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            date = data.get("commit", {}).get("committer", {}).get("date")
            if date:
                return date
    except Exception as exc:
        logging.warning("Could not fetch commit timestamp for %s/%s: %s", repo, commit_sha, exc)

    return ""


def build_release_spec(release: dict) -> FlutterReleaseSpec:
    """Read and cross-check every upstream identity used by source ebuilds."""
    version = release.get("version")
    framework_revision = release.get("hash")
    dart_sdk_version = release.get("dart_sdk_version")
    release_date = release.get("release_date")
    if not all(isinstance(item, str) for item in (
        version, framework_revision, dart_sdk_version, release_date,
    )):
        raise ValueError("Flutter stable release metadata is incomplete")
    framework_revision = checked_sha(framework_revision, "Flutter release hash")
    engine_revision = checked_sha(
        get_flutter_internal_version(framework_revision, "engine.version"),
        "Flutter Engine revision",
    )
    dart_revision = get_deps_dart_revision(framework_revision, "Flutter")
    engine_dart_revision = get_deps_dart_revision(engine_revision, "Engine")
    if dart_revision != engine_dart_revision:
        raise ValueError(
            "Flutter and Engine DEPS pin different Dart revisions: "
            f"{dart_revision} != {engine_dart_revision}"
        )
    fonts_revision = checked_sha(
        extract_hash_from_url_like(
            get_flutter_internal_version(framework_revision,
                                         "material_fonts.version")
        ),
        "Material fonts revision",
    )
    gradle_revision = checked_sha(
        extract_hash_from_url_like(
            get_flutter_internal_version(framework_revision,
                                         "gradle_wrapper.version")
        ),
        "Gradle wrapper revision",
    )
    framework_commit_date = (
        get_commit_timestamp("flutter/flutter", framework_revision)
        or release_date
    )
    engine_commit_date = (
        get_commit_timestamp("flutter/flutter", engine_revision)
        or get_commit_timestamp("flutter/engine", engine_revision)
        or release_date
    )
    result = FlutterReleaseSpec(
        version=version,
        framework_revision=framework_revision,
        engine_revision=engine_revision,
        dart_revision=dart_revision,
        dart_sdk_version=dart_sdk_version,
        material_fonts_revision=fonts_revision,
        gradle_wrapper_revision=gradle_revision,
        release_date=release_date,
        host_dart_constraint=check_dart_compatibility(framework_revision),
        framework_commit_date=framework_commit_date,
        engine_commit_date=engine_commit_date,
    )
    result.validate()
    return result

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
    import re
    for p in pkg_dir.glob(f"{basename}-*.ebuild"):
        m = re.match(r'^' + basename + r'-(.*)\.ebuild$', p.name)
        if m:
            v_ver, _ = parse_gentoo_version(m.group(1))
            t_ver, _ = parse_gentoo_version(version)
            if v_ver == t_ver:
                return True
    return False

def check_dart_compatibility(ref: str) -> str:
    '''Extracts the Dart SDK constraint from the Flutter pubspec.yaml.'''
    import urllib.request, re
    url = f"https://raw.githubusercontent.com/flutter/flutter/{ref}/packages/flutter_tools/pubspec.yaml"
    try:
        with urllib.request.urlopen(url) as response:
            yaml_content = response.read().decode('utf-8')
            env_match = re.search(r'^environment:\s*\n(.*?)(?:^\S|\Z)', yaml_content, re.MULTILINE | re.DOTALL)
            if env_match:
                sdk_match = re.search(r'^\s*sdk:\s*"?\'?([^"\'\n#]+)"?\'?', env_match.group(1), re.MULTILINE)
                if sdk_match:
                    return sdk_match.group(1).strip()
    except Exception as e:
        import logging
        logging.error(f"Failed to fetch pubspec.yaml for dart compatibility: {e}")
    raise ValueError(f"Could not determine Dart SDK constraint for Flutter {ref}")

def evaluate_dart_constraint(constraint: str, available_version: str) -> bool:
    '''Evaluates a Dart pub sdk constraint against a given version.'''
    import re
    # Convert available_version (e.g. 3.11.0-r1) into base pub semver (3.11.0)
    avail_base = re.match(r'^(\d+\.\d+\.\d+)', available_version)
    if not avail_base: return False
    avail_str = avail_base.group(1)
    avail_parts = [int(x) for x in avail_str.split('.')]

    # Simple caret constraint evaluator
    if constraint.startswith('^'):
        base = constraint[1:].split('-')[0] # e.g. 3.11.0 from ^3.11.0-0
        if not re.fullmatch(r"\d+\.\d+\.\d+", base):
            return False
        base_parts = [int(x) for x in base.split('.')]

        # >= base && < (base.major + 1)
        if avail_parts[0] != base_parts[0]: return False

        # Check >= base
        if avail_parts[1] > base_parts[1]: return True
        if avail_parts[1] < base_parts[1]: return False
        if avail_parts[2] >= base_parts[2]: return True
        return False

    # Simple >= < evaluator
    # (very basic for standard flutter cases)
    # E.g. ">=3.2.0-0 <4.0.0"
    m = re.match(r'>=([\d\.]+).*?<\s*([\d\.]+)', constraint)
    if m:
        if not re.fullmatch(r"\d+\.\d+\.\d+", m.group(1)) or not re.fullmatch(r"\d+\.\d+\.\d+", m.group(2)):
            return False
        lower = [int(x) for x in m.group(1).split('.')]
        upper = [int(x) for x in m.group(2).split('.')]
        # check >= lower
        if avail_parts[0] < lower[0]: return False
        if avail_parts[0] == lower[0]:
            if avail_parts[1] < lower[1]: return False
            if avail_parts[1] == lower[1] and avail_parts[2] < lower[2]: return False

        # check < upper
        if avail_parts[0] > upper[0]: return False
        if avail_parts[0] == upper[0]:
            if avail_parts[1] > upper[1]: return False
            if avail_parts[1] == upper[1] and avail_parts[2] >= upper[2]: return False

        return True

    return False


def pending_dart_update_run(version: str) -> dict | None:
    """Return a pending run for exactly ``version``, never an unrelated one.

    The Dart workflow's run-name includes the requested version.  That makes
    the dispatch identity inspectable during the small interval before its
    branch and PR are visible remotely.
    """
    result = run_cmd([
        "gh", "run", "list", "--workflow", "dev-lang-dart-source-update.yaml",
        "--json", "status,displayTitle,url,databaseId", "--limit", "30",
    ], capture_output=True)
    runs = json.loads(result.stdout)
    needle = f"Dart source update ({version})"
    for run in runs:
        if run.get("status") in {"queued", "in_progress", "pending"} and run.get("displayTitle") == needle:
            return run
    return None


def dispatch_dart_prerequisite(version: str) -> str:
    """Deduplicate and dispatch the exact host-Dart prerequisite.

    A non-empty result identifies an existing PR, stranded branch, pending
    run, or newly dispatched run.  Lookup failures deliberately propagate:
    callers must not interpret an unknown remote state as permission to make
    another workflow dispatch.
    """
    branch = f"auto-update-dart-source-{version}"
    response = run_cmd([
        "gh", "pr", "list", "--head", branch, "--json", "url", "--state", "open",
    ], capture_output=True)
    prs = json.loads(response.stdout)
    if prs:
        return f"existing prerequisite PR {prs[0]['url']}"
    remote = run_cmd([
        "git", "ls-remote", "--exit-code", "--heads", "origin", branch,
    ], check=False, capture_output=True)
    if remote.returncode == 0:
        return f"stranded prerequisite branch {branch}"
    if remote.returncode != 2:
        raise RuntimeError(f"failed to query prerequisite branch {branch}")
    pending = pending_dart_update_run(version)
    if pending:
        return f"pending prerequisite workflow {pending.get('url', pending.get('databaseId'))}"
    run_cmd([
        "gh", "workflow", "run", "dev-lang-dart-source-update.yaml", "-f", f"version={version}",
    ])
    try:
        pending = pending_dart_update_run(version)
    except Exception as e:
        logging.warning("Dart workflow dispatched but URL lookup is not yet available: %s", e)
        return f"dispatched prerequisite workflow for {version}"
    if pending:
        return f"dispatched prerequisite workflow {pending.get('url', pending.get('databaseId'))}"
    return f"dispatched prerequisite workflow for {version}"

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
            if compare_versions(pr_version, version) == -1:
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
        res = run_cmd(["git", "ls-remote", "--exit-code", "--heads", "origin", f"refs/heads/{branch_name}"], check=False, capture_output=True)
        if res.returncode == 0:
            return True
        elif res.returncode == 2:
            return False
        else:
            logging.error("Failed to query remote branches.")
            sys.exit(1)
    except Exception as e:
        logging.error(f"Failed to query remote branches: {e}")
        sys.exit(1)

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
        sys.exit(1)

def create_virtual_flutter(version: str, work_root):
    # Resolve only providers actually packaged at this exact SDK version.
    # A newer virtual must not claim an older binary is compatible.
    from maintain_virtuals import ensure_virtual
    base_version = version.split("-r")[0]
    return ensure_virtual(work_root, "flutter", base_version)


def create_ebuild_copy(package: str, version: str, work_root, refresh: bool = False):
    pkg_dir = work_root / package
    basename = package.split('/')[-1]
    existing_ebuilds = list(pkg_dir.glob(f"{basename}-*.ebuild"))
    if not existing_ebuilds:
        raise FileNotFoundError(f"No existing ebuild found in {package} to copy from")

    base_version = version.split("-r")[0]

    def sort_key(ebuild_path):
        import re
        m = re.match(r'^' + basename + r'-(.*)\.ebuild$', ebuild_path.name)
        if m:
            return parse_gentoo_version(m.group(1))
        return ([0], 0)

    if refresh:
        same_version = []
        for p in existing_ebuilds:
            m = re.match(r'^' + basename + r'-(.*)\.ebuild$', p.name)
            if m and parse_gentoo_version(m.group(1))[0] == parse_gentoo_version(base_version)[0]:
                same_version.append(p)
        if same_version:
            target_ebuild = sorted(same_version, key=sort_key)[-1]
            candidates = [p for p in existing_ebuilds if p not in same_version]
            if not candidates:
                raise FileNotFoundError(
                    f"No previous ebuild found in {package} before {version}"
                )
            existing_ebuild = sorted(candidates, key=sort_key)[-1]
            logging.info("Refreshing existing %s", target_ebuild.name)
            return existing_ebuild, target_ebuild

    new_ebuild_path = pkg_dir / f"{basename}-{version}.ebuild"
    candidates = [path for path in existing_ebuilds if path != new_ebuild_path]
    if new_ebuild_path.exists() and refresh:
        if not candidates:
            raise FileNotFoundError(
                f"No previous ebuild found in {package} before {version}"
            )
        existing_ebuild = sorted(candidates, key=sort_key)[-1]
        logging.info("Refreshing existing %s", new_ebuild_path.name)
        return existing_ebuild, new_ebuild_path
    existing_ebuild = sorted(existing_ebuilds, key=sort_key)[-1]
    shutil.copy2(existing_ebuild, new_ebuild_path)
    logging.info(f"Copied {existing_ebuild.name} to {new_ebuild_path.name}")
    return existing_ebuild, new_ebuild_path

def release_pr_body(
    old_version: str, version: str, auth_hash: str, engine_rev: str,
    dart_rev: str, fonts_rev: str, gradle_rev: str, compat_msg: str,
    carried_files: list[str] | None = None,
    inherited_patches: list[str] | None = None,
) -> str:
    """Return the canonical, refreshable PR description."""
    carried_files = carried_files or []
    carried_summary = ", ".join(f"`{path}`" for path in carried_files) or "None"
    inherited_patches = inherited_patches or []
    patch_summary = ", ".join(f"`{path}`" for path in inherited_patches) or "None"
    return (
        f"Automated coordinated source package update for Flutter {version}.\n\n"
        f"**Old Packaged Version:** {old_version}\n"
        f"**New Upstream Version:** {version}\n"
        f"**Authoritative Source:** https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json\n"
        f"**Authoritative Revision:** {auth_hash}\n"
        f"**Flutter Engine revision:** {engine_rev}\n"
        f"**Pinned Dart revision:** {dart_rev}\n"
        f"**Host Dart constraint:** {compat_msg}\n"
        f"**Virtual-provider decision:** Exact-version virtual is generated using only packaged, matching source/binary providers; compatibility is never invented.\n"
        f"**Material Fonts revision:** {fonts_rev}\n"
        f"**Gradle Wrapper revision:** {gradle_rev}\n"
        f"**Manifest Generation:** Completed successfully.\n"
        f"**Dependency/exclusion review result:** Needs human review (fail-closed generator policy active).\n"
        f"**Version-qualified non-patch FILESDIR carry-forward:** {carried_summary}\n"
        f"**Inherited immutable patches:** {patch_summary}\n"
        f"**Patch refresh/review result:** Exact patch revisions are inherited from the previous ebuild; source CI must confirm they still apply.\n"
        f"**Tests Performed:** Pending CI runs for g2 lint, pkgcheck, and integration verification.\n\n"
        f"Related to #939\n"
    )


def commit_and_push(branch_name: str, old_version: str, version: str, auth_hash: str, engine_rev: str, dart_rev: str, fonts_rev: str, gradle_rev: str, compat_msg: str, dry_run: bool, carried_files: list[str] | None = None, inherited_patches: list[str] | None = None, refresh: bool = False, synced_files: list[str] | None = None) -> bool:
    if dry_run:
        logging.info("Dry run: Skipping git add, commit, branch checkout, push, and PR creation.")
        return False

    paths_to_add = ["dev-libs/flutter-engine", "dev-lang/flutter", "virtual/flutter"]
    if synced_files:
        paths_to_add.extend(synced_files)
    run_cmd(["git", "add", *paths_to_add])
    res = run_cmd(["git", "status", "--porcelain"], capture_output=True)
    has_changes = bool(res.stdout.strip())
    if not has_changes and not refresh:
        logging.info("No changes to commit.")
        return False

    if has_changes:
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
    else:
        logging.info("Refresh found no file changes; rescheduling validation.")

    body = release_pr_body(
        old_version, version, auth_hash, engine_rev, dart_rev, fonts_rev,
        gradle_rev, compat_msg, carried_files, inherited_patches,
    )

    try:
        if refresh:
            run_cmd([
                "gh", "pr", "edit", branch_name,
                "--title", f"dev-lang/flutter: bump to {version} (source)",
                "--body", body,
            ])
            logging.info("PR refreshed successfully.")
        else:
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
        logging.error("Failed to create or refresh PR using gh CLI.")
        raise
    return True


def workflow_declares_input(workflow_path: Path, input_name: str) -> bool:
    if not workflow_path.exists():
        return False
    content = workflow_path.read_text(encoding="utf-8")
    in_dispatch = False
    in_inputs = False
    for line in content.splitlines():
        trimmed = line.strip()
        if trimmed == "workflow_dispatch:":
            in_dispatch = True
        elif in_dispatch and trimmed.startswith("inputs:"):
            in_inputs = True
        elif in_inputs:
            if re.match(r"^[a-zA-Z0-9_-]+:", line) and not line.startswith(" "):
                break
            if trimmed.startswith(f"{input_name}:"):
                return True
    return False


def ensure_branch_compatibility(repo_root: Path, tool_dir: Path) -> list[str]:
    """Ensure the target branch has compatible workflows and generator scripts."""
    synchronized = []
    workflows_to_sync = [
        "dev-lang-flutter-source-test.yaml",
        "dev-libs-flutter-engine-source-test.yaml",
        "flutter-engine-dart-pin-regression.yaml",
    ]
    scripts_to_sync = [
        "flutter_release_spec.py",
        "check_flutter_engine_dart_pins.py",
        "generate_flutter_ebuild.py",
        "generate_flutter_engine_ebuild.py",
        "source_update_utils.py",
        "test_flutter_release_pipeline.py",
    ]
    for wf in workflows_to_sync:
        src = tool_dir / "workflows" / wf
        dst = repo_root / ".github" / "workflows" / wf
        if src.exists():
            if not dst.exists() or dst.read_bytes() != src.read_bytes():
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)
                synchronized.append(str(dst.relative_to(repo_root)))
    for sc in scripts_to_sync:
        src = tool_dir / sc
        dst = repo_root / "scripts" / sc
        if src.exists():
            if not dst.exists() or dst.read_bytes() != src.read_bytes():
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)
                synchronized.append(str(dst.relative_to(repo_root)))
    return synchronized


def trigger_release_validation(branch_name: str, version: str, repo_root: Path = REPO_ROOT) -> None:
    """Dispatch read-only validation workflows on the reviewed PR branch."""
    base_version = version.split("-r")[0]
    workflows = (
        ("flutter-engine-dart-pin-regression.yaml", "flutter_version", [
            "-f", f"flutter_version={base_version}", "-f", "full_render=true",
        ]),
        ("dev-libs-flutter-engine-source-test.yaml", "flutter_version", [
            "-f", f"flutter_version={base_version}",
        ]),
        ("dev-lang-flutter-source-test.yaml", "flutter_version", [
            "-f", f"flutter_version={base_version}",
        ]),
    )
    for workflow, req_input, inputs in workflows:
        wf_path = repo_root / ".github" / "workflows" / workflow
        if not workflow_declares_input(wf_path, req_input):
            logging.warning(
                "Workflow %s does not declare input %s on %s; dispatching without extra inputs",
                workflow, req_input, branch_name,
            )
            run_cmd(["gh", "workflow", "run", workflow, "--ref", branch_name])
        else:
            run_cmd(["gh", "workflow", "run", workflow, "--ref", branch_name,
                     *inputs])

def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Do not push or create PR")
    parser.add_argument("--ref", type=str, help="Force a specific upstream git ref/hash")
    parser.add_argument("--version", type=str, help="Force a specific Flutter version to update to")
    parser.add_argument(
        "--refresh", action="store_true",
        help="Regenerate and validate the existing automated PR for this version",
    )
    args = parser.parse_args(argv)

    try:
        if args.version:
            release_obj = get_flutter_release(args.version)
        else:
            release_obj = get_flutter_release()

        version = release_obj.get("version")
        auth_hash = release_obj.get("hash")

        if not version or not auth_hash:
            logging.error("Flutter stable release metadata is incomplete (missing version or hash). Failing closed.")
            sys.exit(1)

        if args.ref:
            if args.ref != auth_hash:
                logging.error(f"Supplied ref '{args.ref}' does not match authoritative stable hash '{auth_hash}' for version {version}. Failing closed.")
                sys.exit(1)
            ref = args.ref
        else:
            ref = auth_hash

        release_spec = build_release_spec(release_obj)
        if release_spec.framework_revision != ref:
            raise ValueError("release spec does not match the selected Flutter ref")
        version = release_spec.version

        orig_root = REPO_ROOT
        work_root = orig_root

        tools_dir = Path(tempfile.mkdtemp(prefix="flutter_updater_tools_"))
        atexit.register(lambda: shutil.rmtree(tools_dir, ignore_errors=True))
        for script_file in (orig_root / "scripts").glob("*.py"):
            shutil.copy2(script_file, tools_dir)
        wf_dir = tools_dir / "workflows"
        wf_dir.mkdir(parents=True, exist_ok=True)
        for wf_file in (orig_root / ".github" / "workflows").glob("*.yaml"):
            shutil.copy2(wf_file, wf_dir)
        for wf_file in (orig_root / ".github" / "workflows").glob("*.yml"):
            shutil.copy2(wf_file, wf_dir)
        sys.path.insert(0, str(tools_dir))

        if args.dry_run:
            tmpdir = tempfile.mkdtemp(prefix="flutter_update_dry_run_")
            atexit.register(lambda: shutil.rmtree(tmpdir, ignore_errors=True))
            work_root = Path(tmpdir)

            import os
            os.makedirs(work_root / "dev-libs" / "flutter-engine", exist_ok=True)
            os.makedirs(work_root / "dev-lang" / "flutter", exist_ok=True)
            os.makedirs(work_root / "virtual" / "flutter", exist_ok=True)

            for f in (orig_root / "dev-libs" / "flutter-engine").glob("*.ebuild"):
                shutil.copy2(f, work_root / "dev-libs" / "flutter-engine")
            for f in (orig_root / "dev-lang" / "flutter").glob("*.ebuild"):
                shutil.copy2(f, work_root / "dev-lang" / "flutter")
            for f in (orig_root / "virtual" / "flutter").glob("*.ebuild"):
                shutil.copy2(f, work_root / "virtual" / "flutter")

        if not re.match(r"^\d+\.\d+\.\d+$", version):
            logging.info(f"Flutter version {version} does not look like stable release. Skipping.")
            return 0

        logging.info(f"Target Flutter version: {version}")

        branch_name = f"auto-update-flutter-source-{version}"

        branch_exists = check_branch_exists(branch_name)
        pr_exists = check_pr_exists(branch_name)
        if pr_exists and not args.refresh:
            logging.info(f"Open PR for {branch_name} already exists. Exiting (dedup).")
            return 0
        if args.refresh and not pr_exists:
            logging.error(
                "--refresh only operates on an existing open automated PR; "
                "refusing to modify %s", branch_name,
            )
            return 1
        if branch_exists and not pr_exists:
            logging.error(f"Remote branch {branch_name} exists but no open PR is found.")
            logging.error("This indicates a previous run failed between pushing the branch and creating the PR.")
            logging.error("Please manually recover the PR using `gh pr create` or delete the stranded branch.")
            sys.exit(1)

        if ebuild_exists("dev-lang/flutter", version) and not args.refresh:
            logging.info(f"Flutter {version} is already packaged. Exiting.")
            return 0

        if check_superseding_release("flutter-source", version):
            return 0

        engine_rev = release_spec.engine_revision
        dart_rev = release_spec.dart_revision
        fonts_rev = release_spec.material_fonts_revision
        gradle_rev = release_spec.gradle_wrapper_revision

        logging.info(f"Engine: {engine_rev}, Dart: {dart_rev}, Fonts: {fonts_rev}, Gradle: {gradle_rev}")

        required_dart_range = release_spec.host_dart_constraint
        compat_msg = f"Requires Dart host SDK range: {required_dart_range} (Engine pinned to: {dart_rev})"

        if required_dart_range != "0.0.0":
            dart_dir = orig_root / "dev-lang" / "dart"

            found_compatible = False
            for p in dart_dir.glob("dart-*.ebuild"):
                m = re.match(r'^dart-(.*)\.ebuild$', p.name)
                if m:
                    if evaluate_dart_constraint(required_dart_range, m.group(1)):
                        found_compatible = True
                        break

            if not found_compatible:
                logging.error(f"Host Dart SDK requirement {required_dart_range} not satisfied locally.")
                req_base = required_dart_range.replace('^', '').replace('>=', '').split('-')[0].split()[0]
                try:
                    state = dispatch_dart_prerequisite(req_base)
                except Exception as e:
                    logging.error("Failed to resolve Dart prerequisite safely: %s", e)
                    sys.exit(1)
                logging.error("Must resolve Dart %s before Flutter %s: %s", req_base, version, state)
                sys.exit(1)

        synced_files = []
        if not args.dry_run and args.refresh:
            run_cmd(["git", "fetch", "origin", branch_name])
            run_cmd(["git", "checkout", "-B", branch_name,
                     f"origin/{branch_name}"])
            synced_files = ensure_branch_compatibility(orig_root, tools_dir)
        elif not args.dry_run:
            run_cmd(["git", "checkout", "-b", branch_name])
            synced_files = ensure_branch_compatibility(orig_root, tools_dir)

        # Create ebuilds
        previous_engine_ebuild, engine_ebuild = create_ebuild_copy(
            "dev-libs/flutter-engine", version, work_root, args.refresh,
        )
        previous_flutter_ebuild, flutter_ebuild = create_ebuild_copy(
            "dev-lang/flutter", version, work_root, args.refresh,
        )
        previous_version = previous_flutter_ebuild.name.removeprefix("flutter-").removesuffix(".ebuild")
        inherited_patches = inherit_previous_patch_files(
            previous_engine_ebuild,
            engine_ebuild,
            orig_root,
            work_root,
            "dev-libs/flutter-engine",
        )
        inherited_patches.extend(
            inherit_previous_patch_files(
                previous_flutter_ebuild,
                flutter_ebuild,
                orig_root,
                work_root,
                "dev-lang/flutter",
            )
        )
        carried_files = carry_forward_versioned_files(
            previous_engine_ebuild,
            version,
            orig_root,
            work_root,
            "dev-libs/flutter-engine",
        )
        carried_files.extend(
            carry_forward_versioned_files(
                previous_flutter_ebuild,
                version,
                orig_root,
                work_root,
                "dev-lang/flutter",
            )
        )
        if inherited_patches:
            logging.info("Inherited immutable patch files: %s", ", ".join(inherited_patches))
        if carried_files:
            logging.info("Carried version-qualified non-patch FILESDIR assets: %s", ", ".join(carried_files))

        # Update Engine DEPS
        logging.info("Running generate_flutter_engine_ebuild.py to update DEPS")
        with tempfile.TemporaryDirectory(prefix="flutter-release-spec-") as tmp:
            spec_path = Path(tmp) / "release.json"
            release_spec.write(spec_path)
            engine_gen_cmd = [
                sys.executable,
                str(tools_dir / "generate_flutter_engine_ebuild.py"),
                "--release-spec", str(spec_path), "--ebuild", str(engine_ebuild),
            ]
            try:
                run_cmd(engine_gen_cmd)
            except subprocess.CalledProcessError as e:
                logging.error(f"Engine Generator failed. Error: {e}")
                raise
            run_cmd(engine_gen_cmd + ["--check"])

            logging.info("Running generate_flutter_ebuild.py to update PUB DEPS")
            flutter_gen_cmd = [
                sys.executable,
                str(tools_dir / "generate_flutter_ebuild.py"),
                "--release-spec", str(spec_path), "--ebuild", str(flutter_ebuild),
            ]
            try:
                run_cmd(flutter_gen_cmd)
            except subprocess.CalledProcessError as e:
                logging.error(f"Flutter Generator failed. Error: {e}")
                raise
            run_cmd(flutter_gen_cmd + ["--check"])

        try:
            logging.info("Updating manifests via verify_manifest.py")
            verify_manifest_cmd = [
                sys.executable,
                str(tools_dir / "verify_manifest.py"),
                str(work_root / "dev-libs" / "flutter-engine"),
                str(work_root / "dev-lang" / "flutter"),
            ]
            run_cmd(verify_manifest_cmd, cwd=str(work_root))
        except subprocess.CalledProcessError:
            logging.error("verify_manifest.py failed. Failing.")
            sys.exit(1)

        # The source ebuild now exists: publish an exact-version virtual with
        # only providers present in this tree (source and/or binary).
        create_virtual_flutter(version, work_root)

        pr_updated = commit_and_push(
            branch_name,
            previous_version,
            version,
            ref,
            engine_rev,
            dart_rev,
            fonts_rev,
            gradle_rev,
            compat_msg,
            args.dry_run,
            carried_files,
            inherited_patches,
            args.refresh,
            synced_files,
        )
        if pr_updated:
            trigger_release_validation(branch_name, version, orig_root)

    except Exception as e:
        logging.error(f"Update failed: {e}")
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main())
