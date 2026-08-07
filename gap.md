## Missing tooling feature: generator overwrites manual fixes - see https://github.com/arran4/arrans_overlay_workflow_builder/issues/96

The `overlay_workflow_builder_generator` overwrites manual customizations made to the output GitHub Actions workflow files when it regenerates them. This relates to preserving manually edited code segments within the generated outputs. See related discussion in issue: [https://github.com/arran4/arrans_overlay_workflow_builder/issues/72](https://github.com/arran4/arrans_overlay_workflow_builder/issues/72) (if applicable to file overwrites).

Specifically:
- It upgrades `actions/checkout` to `@v7` when memory and conventions specify `@v4`.
- It removes the `g2 ebuild deduplicate` invocation.
- It changes `g2 ebuild next-revision` syntax to an incorrect/older format.
- It alters the `g2-action` linting step syntax (e.g., stripping the `. ` context or removing the `if` guard).

### Potential Solutions:

1. **Inline Marker Preservation (Recommended)**
   - *How it works:* The generator reads the existing workflow file before writing. It looks for user-defined comment blocks like `# BEGIN MANUAL HACK` and `# END MANUAL HACK`. When regenerating the file, it injects these literal blocks back into the new output at the exact same location.
   - *Pros:* Highly flexible. Users can inject custom bash commands (like `g2 ebuild deduplicate` or custom variable mappings) anywhere without modifying the core Go generator logic.
   - *Cons:* Can be brittle if the generator drastically changes the surrounding file structure, causing the markers to become orphaned or placed out-of-order.
   - *Rating:* 4/5 - Best immediate fallback for custom scripts.

2. **Configuration Toggles in `current.config`**
   - *How it works:* Extend `current.config` to support flags like `Workaround Add Deduplicate Step` or `Workaround Use Checkout V4`. The Go template then conditionally renders these sections based on the parsed config.
   - *Pros:* Cleanest integration. It keeps the workflow files purely generated (no hybrid editing).
   - *Cons:* Doesn't scale well for highly custom, one-off bash scripts. The author has to merge a new PR into the generator for every unique edge case.
   - *Rating:* 3/5 - Good for common tasks (like changing checkout versions) but too rigid for complex logic.

3. **External Patch Files**
   - *How it works:* The system generates a raw `.tmp.yaml` file, and then applies a unified diff patch (`package.patch`) residing alongside the config file to produce the final workflow.
   - *Pros:* Standardized way to apply modifications without custom generator logic.
   - *Cons:* Extremely fragile. Every time the generator's whitespace or template shifts slightly, the patch files break and require manual resolution.
   - *Rating:* 1/5 - Too high maintenance.


## Missing feature: generator breaks `SRC_URI` with `${version}`

The generator fails to substitute `v${PV}` or correctly use the parsed `originalVersion` string inside the `SRC_URI` heredoc generation script. When generating some workflows (like `www-apps/pagefind-bin`), it generates `v${originalVersion}/${PV}` in the URL but then fails to assign the proper variables, leading to invalid GitHub asset URLs compared to the previous state. It also removes the suffix part of the download URL replacing it with `${version}` which is evaluated to empty because of missing environment variables in some cases. See related discussion in issue: [https://github.com/arran4/arrans_overlay_workflow_builder/issues/68](https://github.com/arran4/arrans_overlay_workflow_builder/issues/68).

### Potential Solutions:

1. **Templated `SRC_URI` Strings in Config (Recommended)**
   - *How it works:* Modify the `Binary` and `Document` directives in `current.config` to support explicit string replacement variables defined by the user instead of magic guessing. E.g., `Binary amd64=>pagefind-{{.Tag}}-x86_64.tar.gz > pagefind`. The generator maps `{{.Tag}}` directly to the ebuild's `${PV}` syntax.
   - *Pros:* Gives the user total control over how the URI string is formatted, completely avoiding regex or guessing failures inside the generator.
   - *Cons:* Requires a syntax breaking change to the config file format.
   - *Rating:* 5/5 - Solves the root cause of guessing URL strings.

2. **Environment Variable Injection**
   - *How it works:* Ensure the bash scripts injected into the workflow export the missing `${version}` and `${originalVersion}` variables properly before constructing the `SRC_URI` block.
   - *Pros:* Easy fix within the current Go templates without changing the config format.
   - *Cons:* It's a band-aid. It doesn't solve the fact that the generator is incorrectly stripping the suffix (like `.tar.gz`) and replacing it indiscriminately.
   - *Rating:* 2/5 - Fixes the bash error but not the logical URL destruction.

## Missing feature: generator breaks Document extraction syntax - see https://github.com/arran4/arrans_overlay_workflow_builder/issues/98
The generator completely fails to generate workflows from configurations utilizing the `Document` keyword introduced in the `current.config` (e.g. `Document amd64=>reddit-tui_Linux_x86_64.tar.gz > LICENSE.txt > LICENSE.txt`). Workflows for packages using this syntax simply aren't generated.

### Potential Solutions:
1. **Extend Parser & Generator Logic for Document Artifacts (Recommended)**
   - *How it works:* Ensure the `overlay_workflow_builder_generator` correctly parses the `Document` prefix inside `Github Binary Release` blocks and emits `dodoc` instructions alongside `dobin` inside the ebuild string block.
   - *Pros:* Native support for README/LICENSE extraction.
   - *Cons:* Requires generator structural changes.
   - *Rating:* 5/5 - Necessary for feature parity with `current.config`.

### Update: G2 v0.0.91 Addresses Some Linting Issues
Note that the recent `g2` release `v0.0.91` has introduced proper QA policy support and the `-ignore-tag` and `-disable-rule` flags. This means that the linting issue (where `g2 lint` didn't respect ignores or required `. `) may soon be resolvable via configuration rather than manual workflow script hacks, mitigating one of the manual fix overwriting problems listed above.

## Missing feature: generator does not use g2 ebuild deduplicate natively - see https://github.com/arran4/arrans_overlay_workflow_builder/issues/99
The generator currently lacks native code blocks for utilizing `g2 ebuild deduplicate`. It was manually injected into the previous CI scripts as an important step immediately following tag fetching and processing to safely clean up duplicate manifest/ebuild artifacts in the repository. Without it, the CI loop must either manually re-add this step or face repos blowing out with stale/identical revisions.

### Potential Solutions:
1. **Add `g2 ebuild deduplicate` Step After Release Processing Loop (Recommended)**
   - *How it works:* After the `process_releases` for-loop in the generated workflow file completes and all tags/versions are generated, inject a standalone execution step `g2 ebuild deduplicate "${ebuild_dir}"`.
   - *Pros:* Fully automates cleaning old ebuilds, aligning exactly with original manual hacks.
   - *Cons:* N/A - Straightforward injection.
   - *Rating:* 5/5
