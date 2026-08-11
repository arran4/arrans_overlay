#!/usr/bin/env python3
"""Build the concise pull-request summary for scheduled repository maintenance."""

import argparse
import os
import subprocess
from collections import defaultdict
from pathlib import Path


STATUS_LABELS = {
    "A": "added",
    "C": "copied",
    "D": "removed",
    "M": "updated",
    "R": "renamed",
}


def run_git(*args):
    return subprocess.check_output(["git", *args], text=True)


def changed_paths(*pathspecs):
    output = run_git("diff", "--staged", "--name-status", "--", *pathspecs)
    rows = []
    for line in output.splitlines():
        parts = line.split("\t")
        if parts:
            rows.append((parts[0][0], parts[-1]))
    return rows


def shortened_ebuild_name(package_dir, path):
    filename = Path(path).name
    prefix = f"{Path(package_dir).name}-"
    return filename.removeprefix(prefix)


def duplicate_summary(rows):
    removed = defaultdict(list)
    for status, path in rows:
        if status == "D" and path.endswith(".ebuild"):
            package_dir = str(Path(path).parent)
            removed[package_dir].append(shortened_ebuild_name(package_dir, path))

    lines = []
    for package_dir in sorted(removed):
        survivors = sorted(
            shortened_ebuild_name(package_dir, path)
            for path in Path(package_dir).glob("*.ebuild")
        )
        removed_text = ", ".join(f"`{name}`" for name in sorted(removed[package_dir]))
        survivor_text = ", ".join(f"`{name}`" for name in survivors) or "none"
        lines.append(
            f"- `{package_dir}`: removed {removed_text}; remaining {survivor_text}."
        )
    return lines, set(removed)


def metadata_cache_summary(rows):
    if not rows:
        return []
    counts = defaultdict(int)
    for status, _ in rows:
        counts[status] += 1
    count_text = ", ".join(
        f"{count} {STATUS_LABELS.get(status, status)}"
        for status, count in sorted(counts.items())
    )
    return [f"- Metadata cache changes: {count_text}."]


def other_summary(rows, deduplicated_packages):
    """Group non-routine changes by package, omitting expected Manifest updates."""
    grouped = defaultdict(lambda: defaultdict(list))
    for status, path in rows:
        item = Path(path)
        if item.name == "Manifest":
            continue
        package_dir = str(Path(*item.parts[:2])) if len(item.parts) >= 2 else "."
        if (
            package_dir in deduplicated_packages
            and status == "D"
            and path.endswith(".ebuild")
        ):
            continue
        relative_path = str(item.relative_to(package_dir)) if package_dir != "." else path
        grouped[package_dir][status].append(relative_path)

    lines = []
    for package_dir in sorted(grouped):
        details = []
        for status in sorted(grouped[package_dir]):
            paths = ", ".join(
                f"`{path}`" for path in sorted(grouped[package_dir][status])
            )
            details.append(f"{STATUS_LABELS.get(status, status)} {paths}")
        lines.append(f"- `{package_dir}`: {'; '.join(details)}.")
    return lines


def print_section(title, lines):
    if not lines:
        return
    print(f"**{title}:**\n")
    print("\n".join(lines))
    print()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--title-output", type=Path)
    args = parser.parse_args()

    repository_rows = changed_paths(":!metadata/md5-cache")
    dedupe_lines, deduplicated_packages = duplicate_summary(repository_rows)
    print_section("Duplicate ebuilds removed", dedupe_lines)

    cache_rows = changed_paths("metadata/md5-cache")
    cache_lines = metadata_cache_summary(cache_rows)
    if not cache_lines and os.environ.get("EGENCACHE_OUTPUT", "").strip():
        cache_lines = ["- Egencache ran without changing the staged metadata cache."]
    print_section("Egencache update", cache_lines)

    print_section(
        "Other scheduled task changes",
        other_summary(repository_rows, deduplicated_packages),
    )

    title = (
        "Automated daily tasks (egencache & dedupe)"
        if cache_lines
        else "Automated daily tasks (dedupe)"
    )
    if args.title_output:
        args.title_output.write_text(title)


if __name__ == "__main__":
    main()
