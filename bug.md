# Bug Report: `overlay_workflow_builder_generator` Generates Broken Workflow Syntax and Configuration

**Related Issue:** [arran4/arrans_overlay_workflow_builder#103](https://github.com/arran4/arrans_overlay_workflow_builder/issues/103)

## Describe the Bug
The `overlay_workflow_builder_generator` currently generates invalid GitHub Actions workflow code for Gentoo overlays in two specific areas:

1. **Incorrect CLI arguments and output handling for `g2 ebuild next-revision`:**
   The generator produces an invalid shell command for the `g2` tool, passing incorrect arguments and wrongly assuming the command outputs a full filepath instead of just the version string. This causes the workflow to crash immediately with a usage error (`exit code 255`).

2. **Assumption of `md5-cache` generation for `g2 lint`:**
   The generator assumes `md5-cache` will always be present or generated before running the `g2 lint` step. However, if the overlay is configured to disable this cache (e.g., via `cache-formats = ` in `metadata/layout.conf`), `g2 lint` will fail with a `Missing md5-cache` warning (Rule PG0802).

## Steps to Reproduce

### Issue 1: `g2 ebuild next-revision`
1. Configure a GitHub binary release package in `current.config`.
2. Run `overlay_workflow_builder_generator` to generate the update workflow.
3. Observe the generated bash block for `check-and-create-ebuild`:
```bash
next_ebuild_file=$(g2 ebuild next-revision "${ebuild_dir}/${{ env.epn }}-${version}" -inspect "$tmp_ebuild_file")
```
4. Run the workflow. It will fail with:
```
usage: g2 ebuild next-revision [--inspect <new_ebuild_file>] <ebuildDir> <version>
```

### Issue 2: `md5-cache` linting error
1. Disable `md5-cache` in your overlay by setting `cache-formats = ` in `metadata/layout.conf`.
2. Generate a workflow using the builder.
3. Observe the generated `g2 lint` action:
```yaml
      - name: Lint output
        uses: arran4/g2-action@v1.2
        with:
          mode: 'run'
          action: 'lint . ${{ env.ecn }}/${{ env.epn }}'
```
4. Run the workflow. It will fail with:
```
[Warning] Missing md5-cache for ebuild txtar-bin-0.0.4
Error: Process completed with exit code 255.
```

## Expected Behavior
### For Issue 1:
The generator should output the correct command and reconstruct the file path securely using the returned version string:
```bash
next_version=$(g2 ebuild next-revision --inspect "$tmp_ebuild_file" "${ebuild_dir}" "${version}")
if [ $? -eq 0 ]; then
    next_ebuild_file="${ebuild_dir}/${{ env.epn }}-${next_version}.ebuild"
```

### For Issue 2:
The workflow builder should respect the overlay's configuration natively. If the overlay has explicitly disabled cache generation, the workflow builder should not generate steps or enforce lint rules that rely on it.

Specifically, the workflow builder should parse the repository's `metadata/layout.conf` during generation. If `cache-formats = ` (empty) or if `md5-dict` is omitted, the builder should format the `g2 lint` command appropriately to disable the `PG0802` rule.

Expected generated workflow syntax when `cache-formats` is empty:
```yaml
      - name: Lint output
        uses: arran4/g2-action@v1.2
        with:
          mode: 'run'
          action: 'lint -disable-rule PG0802 . ${{ env.ecn }}/${{ env.epn }}'
```
