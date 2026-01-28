# Agent Guidelines

This repository uses [arrans_overlay_workflow_builder](https://github.com/arran4/arrans_overlay_workflow_builder) to manage many of its ebuilds and workflows. Please follow these guidelines to maintain consistency and stability.

## 1. The Workflow Builder & `current.config`

The `current.config` file is the **source of truth** for all packages managed by the builder.

*   **Generated File Headers:** Generated files must include a comment at the top stating they are generated and listing the tool used.
*   **Do not manually edit generated ebuilds** (files usually ending in `-bin.ebuild` or `-appimage.ebuild` that appear in `current.config`).
*   **To Add/Update a Package using generated code from overlay_workflow_builder_generator:**
    1.  Modify `current.config`.
    2.  If you have the `overlay_workflow_builder_generator` tool locally, run it to regenerate the workflows and ebuilds.
    3.  Otherwise, commit the change to `current.config` and let the Github Actions workflows handle the regeneration.
*   **Config Structure:**
    *   `Type`: The type of upstream source (e.g., `Github Binary Release`, `Github AppImage Release`).
    *   `GithubProjectUrl`: The upstream repo.
    *   `EbuildName`: The target filename (must include `.ebuild`).
    *   `Binary`/`Document`: Mappings from upstream artifacts to installed files.

## 2. Updating Applications

There are two primary methods for updates:

### Automated Updates (Generated)
*   The workflows in `.github/workflows/` (ending in `-update.yaml`) run on a schedule.
*   They check for new upstream releases.
*   If a new version is found, the workflow updates the ebuild, regenerates the Manifest, and runs cleanup scripts.

### Manual Updates
*   For packages **not** in `current.config` (e.g., complex source builds, `-9999` live ebuilds, or packages requiring manual patches), you must edit the ebuild manually.
*   After editing, always run `g2 manifest upsert-from-url <url> <filename> <path_to_manifest>` to update the Manifest.

## 3. Versioning Policy

To keep the overlay clean, we follow a **"One Version Per Grade"** policy.

*   **Grades:** We distinguish between stability grades: `release` (stable), `alpha`, `beta`, `rc`, `pre`, `test`.
*   **The Rule:** Keep only the **latest** version for *each* grade that exists.
    *   *Example:* You can have `1.0.0` (release) AND `1.1.0_alpha2` (alpha).
    *   *Cleanup:* If `1.1.0_alpha3` is released, `1.1.0_alpha2` should be removed.
*   **Tooling:** This logic is enforced by `scripts/remove_duplicate_ebuilds.py`. Run this script (or ensure the CI runs it) after adding new versions.

## 4. Safety & Readme

*   **WARNING: Avoid Overwriting `README.md` when installing tools.**
    *   Many tool release tarballs (like `g2`) contain a `README.md`. **Do NOT extract them directly into the repository root**, as this will overwrite the project's README.
    *   **Recommendation:**
        *   Use `go run <package_url>` (e.g., `go run github.com/arran4/g2@latest manifest ...`).
        *   OR extract *only* the binary: `tar -xvf g2_archive.tar.gz g2`.
*   **Manifests:** Use `g2 manifest` commands safely.
*   **Git History:** Write descriptive commit messages explaining *why* a change was made, not just *what* changed.

## 5. Testing & Verification

*   **Testing Script:** Use `scripts/test_ebuilds.sh` to verify changes.
    *   Usage: `scripts/test_ebuilds.sh path/to/package.ebuild`
    *   It checks if the ebuild can `fetch` sources (default) or `merge` (install) if flags are provided.
*   **Manifest Verification:** `scripts/verify_manifest.py` is used in CI to ensure all distfiles are accounted for.
*   **Linting:** Be aware of `pkgcheck` and `actionlint` results in the PR checks.
