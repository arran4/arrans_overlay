# Feature Request: `g2 ebuild deduplicate`

## Summary
Currently, the process of cleaning up old or duplicate ebuilds relies on a custom Python script (`scripts/remove_duplicate_ebuilds.py`) executed within a GitHub Actions workflow (`.github/workflows/scheduled-daily-tasks.yml`). While this script removes duplicate `.ebuild` files, this is a multi-step process that requires running `g2 manifest clean` afterwards in a separate step or via subprocess. We need a native `g2` command that can perform this entire cleanup process in a single, robust operation.

## Detailed Description
We request a new command (e.g., `g2 ebuild deduplicate` or `g2 repo clean`) that handles the following tasks automatically and atomically:

1. **Ebuild Cleanup:**
   - Detect and remove duplicate/old ebuilds for a given package (or across the entire repository) based on versioning.

2. **Manifest Cleanup:**
   - After deleting the older ebuilds, the command **MUST** automatically clean up the `Manifest` file, ensuring it is purged of entries (DIST and EBUILD) corresponding to the removed `.ebuild` files.

3. **Complete Package Removal (If empty):**
   - If the deduplication process removes all `.ebuild` files from a package directory, the command should also automatically clean up:
     - The `Manifest` file itself.
     - The `metadata.xml` file for the package.
     - Any caches related to the package.
     - The package directory itself (e.g., `rmdir` if empty).

## Motivation
The current approach requires external Python scripting. Implementing this logic directly in `g2` would ensure a consistent, safe, and integrated workflow for repository maintenance, cleaning up ebuilds, manifests, metadata.xml, and caches without needing multiple steps or external scripts.
