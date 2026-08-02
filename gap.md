## Missing Features / Workarounds Required in `arrans_overlay_workflow_builder`

### 1. Preservation of Manual Workflow Adjustments
Currently, the generator completely overwrites any manual modifications made to the workflows when updating them based on `current.config`. Examples of broken functionality and lost manual work include:
- Dropping custom `pkg_postinst()` functions injected into the ebuild generation blocks (e.g., in `gocdm-bin`).
- Reverting custom metadata usage (e.g., in `gocdm-bin`, the target uses `g2 metadata ... --use-add ...` but the generator drops the extra arguments).
- Overwriting custom `LICENSE`, `IUSE`, and `RDEPEND` arrays that are configured in the workflows directly.
- Modifying standard GitHub Actions syntax such as unintentionally dropping `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` and incorrectly downgrading/upgrading checkout action versions.
- Modifying or destroying custom loop structures for `g2 ebuild next-revision` and `g2 manifest upsert-from-url`.

### 2. Malformed SRC_URI URLs in v0.1.33
The `v0.1.33` release generates malformed `SRC_URI` and `upsert-from-url` fields containing invalid variables. For example, it substitutes parts of the URL with `${originalVersion}` and unescaped `\${PV}` in ways that lead to `404 Not Found` errors during the release download step.

---

## Proposed Solutions (Alternatives)

To resolve issue #1 (Preservation of Manual Workflow Adjustments), the following proposals are presented. **These are alternatives to each other**; only one of these approaches needs to be implemented.

### Proposal A: Inline Block Preservation (Manual Overrides)
Support a mechanism within the generated GitHub Action workflows that protects specific lines or blocks from being overwritten during subsequent generator runs.
- **Implementation:** The generator would parse existing `.yaml` files before overwriting them. Any content found between specific marker comments (e.g., `# MANUAL OVERRIDE START` and `# MANUAL OVERRIDE END`) would be extracted and injected into the newly generated file at the exact same location.
- **Pros:** Keeps all logic inside the GitHub Actions YAML file, making it easy for contributors to read and modify directly.
- **Cons:** Requires the generator to parse existing output files which adds complexity to the generation logic.
- **Example:**
  ```yaml
  # In the generated .github/workflows/gocdm-bin-update.yaml

  # MANUAL OVERRIDE START - Custom pkg_postinst
  echo 'pkg_postinst() {'
  echo '  einfo "To run GoCDM directly from tty1 under systemd, override getty@tty1.service:"'
  echo '  einfo "sudo systemctl edit getty@tty1.service"'
  echo '}'
  # MANUAL OVERRIDE END
  ```
  *(This relies on the generator's source code being updated to detect these markers during generation and inject the enclosed content instead of default generation for that block.)*

### Proposal B: Templating / Partial Overrides via Config
Expand the `current.config` syntax to support specific single-line directives that map to external script files, avoiding the need for multi-line block parsing in the config parser.
- **Implementation:** Introduce directives that point to a relative file path (e.g., `CustomEbuildScript`, `CustomMetadataArgs`, `CustomEnvVars`). The generator reads these external files and injects their contents directly into the generated workflow.
- **Pros:** Avoids extending the config parser to handle multi-line blocks while cleanly separating concerns.
- **Cons:** Still requires creating additional files in the repository.
- **Example:**
  ```text
  # In current.config
  Type Github Binary Release
  GithubProjectUrl https://github.com/arran4/gocdm
  EbuildName gocdm-bin
  CustomEbuildScript config/gocdm-bin/postinst.sh
  ```
  *(Alternatively, more specific single-line overrides like `OverrideLicense MIT` or `OverrideRDepend "sys-fs/fuse:0"` could be added to avoid external files entirely.)*

### Proposal C: Extensible Ebuild Generation Script (Hook System)
Instead of generating the entire bash script that builds the `.ebuild` file directly into the workflow YAML, the generator could output calls to modular bash scripts (or hooks) stored in the repository.
- **Implementation:** The workflow calls `generate_ebuild.sh <package>`. The `generate_ebuild.sh` script provides a framework that allows repository maintainers to drop in a `custom_postinst.sh` or `custom_metadata.sh` file into a package directory, which the main script automatically executes during the generation process.
- **Pros:** Highly flexible; leverages standard bash instead of custom config directives or YAML parsing.
- **Cons:** Requires a significant architectural rewrite of how the workflow builder integrates with the repository's CI pipeline.
- **Example:**
  ```bash
  # Inside a new repository file: ./app-misc/gocdm-bin/custom_postinst.sh
  cat << 'EOM' >> "$tmp_ebuild_file"
  pkg_postinst() {
    einfo "To run GoCDM directly from tty1 under systemd, override getty@tty1.service:"
  }
  EOM
  ```
  *(The workflow generator would output a step to source any `custom_*.sh` scripts found in the package directory before finalizing the ebuild.)*

### Proposal D: Diff-based Patch Application (Post-Generation Hook)
Allow repository maintainers to maintain standard `.patch` or `.diff` files for specific packages that the workflow builder automatically applies *after* generating the workflow files, but *before* the CI job considers them final.
- **Implementation:** The workflow generator could output a final step in its own execution that runs `git apply config/patches/<package>.patch` if the file exists.
- **Pros:** Completely isolates the generator code from having to understand or parse manual overrides; patch files are a well-understood, standard tool for applying overrides to generated or upstream code.
- **Cons:** Patch files can become brittle if the underlying generated workflow structure changes significantly, requiring frequent manual rebasing.
- **Example:**
  ```diff
  # config/patches/gocdm-bin.patch
  @@ -97,6 +97,7 @@
   echo 'LICENSE="MIT"'
  -echo 'RDEPEND=""'
  +echo 'RDEPEND="sys-fs/fuse:0"'
  ```

### Proposal E: JSON/YAML Config Object Merging
Transition `current.config` from its current custom plaintext format to a structured format like YAML or JSON, which natively supports multi-line strings, nested objects, and arrays.
- **Implementation:** The `overlay_workflow_builder_generator` is rewritten to accept a `config.yaml` file. The generator deep-merges default configurations with any package-specific overrides provided in the YAML object.
- **Pros:** Completely eliminates the custom config parser limitations. Natively supports multi-line scripts (like `pkg_postinst`) as string literals within the YAML file.
- **Cons:** Requires users to migrate their entire `current.config` to the new format and entails a significant rewrite of the generator's config parsing logic.
- **Example:**
  ```yaml
  # config.yaml
  packages:
    - type: Github Binary Release
      projectUrl: https://github.com/arran4/gocdm
      ebuildName: gocdm-bin
      overrides:
        license: MIT
        rdepend: sys-fs/fuse:0
        postinst: |
          pkg_postinst() {
            einfo "To run GoCDM directly from tty1 under systemd..."
          }
  ```

---

## Current Immediate Workarounds

Until one of the above proposals is implemented, the current workaround is to write a script that updates the generated workflows but restores the manual overrides using text replacement.

1. Generate the workflows into a temporary directory:
   ```bash
   ./overlay_workflow_builder_generator generate workflows -input-file current.config -output-dir /tmp/workflows
   ```
2. Write a Python script (`update_workflows.py`) that reads the new templates from `/tmp/workflows`, manually replaces the broken URLs using regex (e.g., swapping `${originalVersion}` for `\${PV}`), injects the custom logic (like `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true`), and then overwrites the files in `.github/workflows/`.
3. For heavily customized files (like `gocdm-bin-update.yaml` or `codex-bin-update.yaml`), add a comment `# This workflow was originally generated but is now manually maintained` to the top of the file in the repository, and instruct the Python script to skip updating those specific files entirely.
