## Missing tooling feature: generator overwrites manual fixes

The `overlay_workflow_builder_generator` overwrites manual customizations made to the output GitHub Actions workflow files when it regenerates them.

Specifically:
- It upgrades `actions/checkout` to `@v7` when memory and conventions specify `@v4`.
- It removes the `g2 ebuild deduplicate` invocation.
- It changes `g2 ebuild next-revision` syntax to an incorrect/older format.
- It alters the `g2-action` linting step syntax (e.g., stripping the `. ` context or removing the `if` guard).

**Potential solution:**
Implement a way for the config or generator to preserve manual script logic between specific `BEGIN_MANUAL_HACK` and `END_MANUAL_HACK` comments, or expose configuration toggles for these behaviors within `current.config` directly. This would prevent the need for manual `sed` patches after running the generator.

## Missing feature: generator breaks `SRC_URI` with `${version}`

The generator fails to substitute `v${PV}` or correctly use the parsed `originalVersion` string inside the `SRC_URI` heredoc generation script. When generating some workflows (like `www-apps/pagefind-bin`), it generates `v${originalVersion}/${PV}` in the URL but then fails to assign the proper variables, leading to invalid GitHub asset URLs compared to the previous state.
It also removes the suffix part of the download URL replacing it with `${version}` which is evaluated to empty because of missing environment variables in some cases.

**Potential solution:**
Update the `overlay_workflow_builder_generator` to allow precise formatting rules per artifact, perhaps extending the string formatting template language in `current.config` to allow `\${PV}` explicitly for GitHub asset names instead of trying to autodetect or replace strings inconsistently.
