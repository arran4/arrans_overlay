# TODOs for Tooling Upgrades

1. **`current.config` generator updates needed**:
   - The manually maintained workflow `.github/workflows/net-im-beeper-appimage-update.yaml` uses a non-standard redirect URL for its AppImage (`https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop`) and has a hardcoded download of `htmlq` via `gh release download` (previously `wget`). The `overlay_workflow_builder_generator` does not natively support either of these currently.
   - The workflow `.github/workflows/app-misc-kllamabooks-update.yaml` is manually maintained because it builds from source, which isn't currently supported by the generator.
   - The workflow `.github/workflows/dev-util-junie-bin-update.yaml` is manually maintained because it gets its version tags from a custom `update-info.jsonl` rather than normal GitHub releases.
   - The workflow `.github/workflows/app-admin-google-cloud-sdk-update.yaml` extracts versions via a custom `curl` parsing HTML release notes.
   - The workflow `.github/workflows/www-misc-which_browser-update.yaml` extracts filenames from an `index.xml` feed rather than standard GitHub releases.
2. **Generator updates needed for `actions/checkout`**:
   - The `overlay_workflow_builder_generator` currently emits `uses: actions/checkout@v2`. This causes Node.js 20 deprecation warnings on GitHub Actions because it forces actions to run on Node.js 24. I manually updated them to `v4` in the generated workflows as a temporary fix, but the generator's template itself needs to be updated.
