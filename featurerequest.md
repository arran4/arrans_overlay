### Feature Request: `g2 ebuild upsert-from-stdin` (or `resolve-revision`)

**Problem Statement:**
When managing ebuilds via GitHub Action generation templates (such as `overlay_workflow_builder_generator`), we occasionally need to manually create a bumped revision (e.g., `program-1.2-r1.ebuild`) to fix an issue, and subsequently delete the base version (`program-1.2.ebuild`).

Currently, when the GitHub Action runs, it checks for the absence of the base `program-1.2.ebuild`. Seeing it missing, it blindly regenerates it. This creates a duplicate grade issue (having both the base and `-r1`), which causes automated cleanup scripts (`scripts/remove_duplicate_ebuilds.py`) to enter an infinite loop of deleting and regenerating files.

Furthermore, if an upstream release triggers a workflow regeneration where only the generated timestamp comments change (but the actual ebuild parameters do not), it would be ideal to ignore the change entirely, or bump to a new revision (`-r#`) if the uncommented core content actually differs. Right now, this logic requires a complex and messy Bash script injected into every workflow.

**Proposed Solution:**
Add a robust command that reads generated ebuild content from `stdin` and handles the versioning logic safely in Go.

```bash
g2 ebuild upsert --dir <ebuildDir> --package <pkgName> --version <version> [--ignore-comments]
```

**Behavior Requirements:**
1. Scans `<ebuildDir>` for the highest existing revision of `<version>` (including the base `-r0`).
2. If no files exist for that version, writes `stdin` to the base `.ebuild` file.
3. If files exist, diffs `stdin` against the highest revision (optionally ignoring lines matching `^\s*#` to ignore generator timestamps).
4. If identical, skips writing and exits successfully.
5. If they differ, increments the highest revision number and writes the new content to `-r<num>.ebuild`.
6. Outputs the final file path that was written to stdout, or an empty string if no write occurred, so workflow templates can conditionally generate manifests.

This will massively simplify workflow templates and solve revision cleanup loops entirely within the `g2` ecosystem without relying on fragile inline Bash logic!
