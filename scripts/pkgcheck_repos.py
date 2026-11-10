#!/usr/bin/env python3
"""Clone pkgcheck master repos and configure their Docker mounts from .pkgcheck-repos."""

import argparse
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit

OVERLAY_NAME = "arrans-overlay"
IMAGE = "ghcr.io/pkgcore/pkgcheck:latest"
ROOT = Path(__file__).resolve().parent.parent
NAME_PATTERN = re.compile(r"^[a-z0-9][a-z0-9_-]*$")


@dataclass(frozen=True)
class Repository:
    name: str
    url: str


def parse_repositories(text: str) -> list[Repository]:
    """Parse name/URL entries, stripping full-line and trailing # comments."""
    repos = []
    seen_names = set()
    for line_number, raw_line in enumerate(text.splitlines(), start=1):
        line = raw_line.partition("#")[0].strip()
        if not line:
            continue
        fields = line.split()
        if len(fields) != 2:
            raise ValueError(f".pkgcheck-repos:{line_number}: expected <name> <url>")
        name, url = fields
        parsed = urlsplit(url)
        if not NAME_PATTERN.fullmatch(name) or name == OVERLAY_NAME:
            raise ValueError(f".pkgcheck-repos:{line_number}: invalid repository name: {name}")
        if parsed.scheme != "https" or not parsed.hostname or not parsed.path or parsed.username or parsed.password:
            raise ValueError(f".pkgcheck-repos:{line_number}: expected an HTTPS Git URL: {url}")
        if name in seen_names:
            raise ValueError(f".pkgcheck-repos:{line_number}: duplicate repository: {name}")
        seen_names.add(name)
        repos.append(Repository(name, url))
    if not repos:
        raise ValueError(".pkgcheck-repos: no repositories listed")
    return repos


def read_masters(text: str) -> list[str]:
    """Use the overlay's actual metadata/layout.conf masters, not a duplicated list."""
    for raw_line in text.splitlines():
        line = raw_line.partition("#")[0].strip()
        key, sep, value = line.partition("=")
        if sep and key.strip() == "masters":
            masters = value.strip().split()
            if masters:
                return masters
    raise ValueError("metadata/layout.conf must declare at least one master")


def validate_masters(repos: list[Repository], masters: list[str]) -> None:
    listed = {repo.name for repo in repos}
    missing = set(masters) - listed
    if missing:
        raise ValueError(f".pkgcheck-repos: missing overlay masters: {', '.join(sorted(missing))}")
    if "gentoo" not in listed:
        raise ValueError(".pkgcheck-repos: gentoo required for the CI amd64 profile")


def write_portage_config(config_dir: Path, repos: list[Repository], masters: list[str]) -> None:
    for repo in repos:
        (config_dir / f"{repo.name}.conf").write_text(
            f"[{repo.name}]\nlocation = /var/db/repos/{repo.name}\nauto-sync = no\n"
        )
    (config_dir / f"{OVERLAY_NAME}.conf").write_text(
        f"[{OVERLAY_NAME}]\nlocation = /var/db/repos/{OVERLAY_NAME}\n"
        f"masters = {' '.join(masters)}\nauto-sync = no\n"
    )


def docker_command(root: Path, config_dir: Path, repos: list[Repository]) -> list[str]:
    command = [
        "docker", "run", "--rm",
        "-v", f"{root}:/var/db/repos/{OVERLAY_NAME}",
        "-v", f"{config_dir}:/etc/portage/repos.conf:ro",
    ]
    for repo in repos:
        command.extend(["-v", f"{root / 'repos' / repo.name}:/var/db/repos/{repo.name}:ro"])
    command.extend([
        IMAGE, "bash", "-euxo", "pipefail", "-c",
        "ln -snf /var/db/repos/gentoo/profiles/default/linux/amd64/23.0 "
        "/etc/portage/make.profile; "
        f"cd /var/db/repos/{OVERLAY_NAME}; "
        f"git config --global --add safe.directory /var/db/repos/{OVERLAY_NAME}; "
        "pkgcheck scan --exit GentooCI --keywords=-UnknownManifest --commits",
    ])
    return command


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="validate the repo list without cloning")
    args = parser.parse_args(argv)

    repos = parse_repositories((ROOT / ".pkgcheck-repos").read_text())
    masters = read_masters((ROOT / "metadata/layout.conf").read_text())
    validate_masters(repos, masters)
    if args.check:
        print("Valid pkgcheck repos: " + ", ".join(repo.name for repo in repos))
        return 0

    repos_dir = ROOT / "repos"
    repos_dir.mkdir(exist_ok=True)
    for repo in repos:
        print(f"Cloning {repo.name} from {repo.url}", flush=True)
        subprocess.run(
            ["git", "clone", "--depth=1", "--", repo.url, str(repos_dir / repo.name)],
            check=True,
        )

    with tempfile.TemporaryDirectory(prefix="pkgcheck-repos-") as temporary:
        config_dir = Path(temporary)
        write_portage_config(config_dir, repos, masters)
        subprocess.run(docker_command(ROOT, config_dir, repos), check=True)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"pkgcheck repository setup failed: {error}", file=sys.stderr)
        sys.exit(1)
