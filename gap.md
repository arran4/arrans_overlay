# Feature Requests for Tooling

## `overlay_workflow_builder_generator` Gaps

### 1. Support for Custom Download URLs and Artifact Extraction ([Issue #67](https://github.com/arran4/arrans_overlay_workflow_builder/issues/67))
Currently, the generator assumes standard GitHub release URLs. Some packages use custom URLs or extraction methods:
- **`net-im/beeper-appimage`**: Downloads from a custom API (`https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop`). It also relies on `htmlq` (downloaded separately) to parse the version. The generator needs a way to support a custom `DownloadUrl` logic and auxiliary tool execution in the update workflow.
- **`app-misc/kllamabooks`**: Requires building from source rather than downloading a release artifact, which the generator doesn't currently support.
- **`dev-util/junie-bin`**: Version tags are pulled from a custom `update-info.jsonl` rather than standard GitHub releases.
- **`app-admin/google-cloud-sdk`**: Versions are extracted by parsing HTML release notes with `curl` and `grep` rather than using the GitHub API.
- **`www-misc/which_browser`**: Filenames are extracted from an `index.xml` RSS feed rather than standard GitHub release assets.

**Proposed Feature:** Add configuration properties in `current.config` (e.g., `CustomDownloadUrl`, `CustomVersionSource`, `CustomBuildSteps`) that inject manual bash logic into the generated workflow while still utilizing the generator's structure.

### 2. Node.js Version Bumping ([Issue #68](https://github.com/arran4/arrans_overlay_workflow_builder/issues/68))
The generator currently emits `uses: actions/checkout@v2`. This causes Node.js 20 deprecation warnings on GitHub Actions because `v2` is outdated.
**Proposed Feature:** Update the generator's internal workflow templates to emit `uses: actions/checkout@v4` by default.

### 3. HOMEPAGE Field Generation ([Issue #69](https://github.com/arran4/arrans_overlay_workflow_builder/issues/69))
The generator lacks support for generating the `HOMEPAGE` field in `github-appimage` and `Github Binary Release` generated ebuilds based on `current.config`. We currently have to manually inject this using `sed` in the ebuild (or workflow template).
**Proposed Feature:** Extract the `Homepage` variable from `current.config` and natively inject it into the generated ebuild templates.
