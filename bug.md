# Workflow Generator Bug Report

The `arrans_overlay_workflow_builder` generates workflows with environment variables incorrectly placed under `concurrency` or directly at the top level instead of wrapping them in a top-level `env:` block.

This caused the workflow files to fail validation with "Unexpected value" errors in GitHub Actions. We had to manually wrap these variables into `env:` blocks to correct them. The generator should be updated to place these variables in an `env:` block natively.

Additionally, some types are not correctly supported or have case sensitivity issues. For example, `github-appimage` in `current.config` fails with `uknown type: github-appimage`, while `Github AppImage Release` works.
