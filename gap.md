## Missing Features / Workarounds Required in `arrans_overlay_workflow_builder`

1. **Preservation of Manual Workflow Adjustments:**
   Currently, the generator overwrites any manual modifications made to the workflows. Examples of broken functionality include:
   - Dropping custom `pkg_postinst()` functions injected into the ebuild generation blocks (e.g., in `gocdm-bin`).
   - Reverting custom metadata usage (e.g., in `gocdm-bin`, the target uses `g2 metadata ... --use-add ...` but the generator drops it).
   - Overwriting custom `LICENSE`, `IUSE`, and `RDEPEND` arrays configured outside of `current.config`.
   - Modifying standard GitHub Actions syntax such as dropping `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` and downgrading/upgrading checkout action versions incorrectly.
   - Modifying the custom loop for `g2 ebuild next-revision` and `g2 manifest upsert-from-url`.

   **Recommendation:** Support a templating override mechanism or preserve blocks marked with `# MANUAL OVERRIDE START` ... `# MANUAL OVERRIDE END`.

2. **Malformed SRC_URI URLs in v0.1.33:**
   The `v0.1.33` release generates malformed `SRC_URI` fields containing invalid variables. For example, it substitutes parts of the URL with `${originalVersion}` and unescaped `\${PV}` in ways that lead to 404 Not Found errors during download.
