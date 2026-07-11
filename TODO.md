# TODOs for Tooling Upgrades

1. **`current.config` generator updates needed**:
   - The manually maintained workflow `.github/workflows/net-im-beeper-appimage-update.yaml` uses a non-standard redirect URL for its AppImage (`https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop`) and has a hardcoded download of `htmlq` via `gh release download` (previously `wget`). The `overlay_workflow_builder_generator` does not natively support either of these currently.
   - The workflow `.github/workflows/app-misc-kllamabooks-update.yaml` is manually maintained because it builds from source, which isn't currently supported by the generator.
   - The workflow `.github/workflows/dev-util-junie-bin-update.yaml` is manually maintained because it gets its version tags from a custom `update-info.jsonl` rather than normal GitHub releases.
   - The workflow `.github/workflows/app-admin-google-cloud-sdk-update.yaml` extracts versions via a custom `curl` parsing HTML release notes.
   - The workflow `.github/workflows/www-misc-which_browser-update.yaml` extracts filenames from an `index.xml` feed rather than standard GitHub releases.
2. **Additional `gh` migrations needed**:
   - The workflow `.github/workflows/dev-lang-flutter-bin-update.yaml` uses commented out `wget` commands that might be replacable if they are uncommented later, though they pull from Google Cloud Storage, not GitHub releases, so `gh release download` won't apply.
   - For all generated workflows, `overlay_workflow_builder_generator` now correctly uses `arran4/g2-action@v1.2` for its g2 installation instead of manual `curl`/`wget` scripts, fulfilling the request for general `g2` updates!
   - The workflow `.github/workflows/dev-util-codex-bin-update.yaml` is manually maintained because upstream uses a non-standard "rust-v" tag prefix which needs custom stripping logic, which isn't currently natively supported by the generator.
