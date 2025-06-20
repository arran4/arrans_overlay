# Agent Guidelines

This repository contains many ebuilds and workflows that are generated automatically using [arrans_overlay_workflow_builder](https://github.com/arran4/arrans_overlay_workflow_builder). When updating packages:

- **Do not manually edit generated ebuilds.** Instead adjust `current.config` and regenerate the workflow using the builder.
- After removing an ebuild make sure to also remove any related entries from its `Manifest` file. If no ebuilds remain, delete the manifest file and package directory entirely.
- Regenerate manifests with `g2 manifest` after adding new distfiles.
- Keep the workflows in `.github/workflows/` up to date with the generator output.
- Commit messages should summarise what changed and include a short description of the reason when possible.


