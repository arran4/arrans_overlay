# Bug Report: `Github Binary Release` workflows fail on empty releases

## Issue Description
The `arrans_overlay_workflow_builder` generates update workflows for `Github Binary Release` types that iterate over all GitHub tags/releases. If a release exists but has no binary assets attached (e.g., a tag created for source code only, or a release that hasn't finished uploading assets), the workflow attempts to construct a download URL and fetch it.

This results in a **404 Not Found** error during the `g2 manifest upsert-from-url` step, causing the entire workflow to fail.

## Steps to Reproduce
1. Configure a package in `current.config` with `Type Github Binary Release`.
2. Target a repository that has a release tag with **no assets** (only Source Code zip/tar.gz).
   - Example: `arran4/flutter_jules` version `v0.0.64`.
3. Run the generated update workflow.

## Observed Behavior
The workflow attempts to download the binary (e.g., `flutter_jules-linux.tar.gz`) from the release URL. Since the asset does not exist, GitHub returns a 404, and the `curl`/`wget` or `g2` command fails.

```
generate error: upsert file from url: downloading and calculating checksums: bad status: 404 Not Found
```

## Expected Behavior
The workflow should identify that the release is not suitable for a binary package update (due to missing assets) and skip it, proceeding to the next available release or exiting gracefully.

## Suggested Fix
Modify the `jq` filter in the generated workflow script to exclude releases with zero assets.

**Current Filter:**
```jq
.[]? | select(type=="object" and has("tag_name")) | .tag_name
```

**Proposed Filter:**
```jq
.[]? | select(type=="object" and has("tag_name") and (.assets | length > 0)) | .tag_name
```
