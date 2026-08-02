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

### Proposal B: Templating / Partial Overrides via Config
Expand the `current.config` syntax (or allow adjacent partial template files) to allow defining custom blocks that override the default generated output for a specific package.
- **Implementation:** Introduce new directives in `current.config` (e.g., `CustomEbuildBlock`, `CustomG2LintAction`, `CustomEnvVars`) or allow specifying an external template file per package that the generator merges with the base template.
- **Pros:** Keeps the source of truth cleanly separated from the generated artifacts, ensuring the generator doesn't need to parse its own previous output.
- **Cons:** Increases the complexity of `current.config` and forces contributors to learn a new templating syntax instead of just modifying standard bash scripts in the workflows.

### Proposal C: Extensible Ebuild Generation Script (Hook System)
Instead of generating the entire bash script that builds the `.ebuild` file directly into the workflow YAML, the generator could output calls to modular bash scripts (or hooks) stored in the repository.
- **Implementation:** The workflow calls `generate_ebuild.sh <package>`. The `generate_ebuild.sh` script provides a framework that allows repository maintainers to drop in a `custom_postinst.sh` or `custom_metadata.sh` file into a package directory, which the main script automatically executes during the generation process.
- **Pros:** Highly flexible; leverages standard bash instead of custom config directives or YAML parsing.
- **Cons:** Requires a significant architectural rewrite of how the workflow builder integrates with the repository's CI pipeline.
