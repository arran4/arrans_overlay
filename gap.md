# Feature Requests / Bug Reports for overlay_workflow_builder_generator

## Issue: Revert of Important Fixes in Workflows
The generator unconditionally overwrites files. This causes it to break custom manual logic that has been inserted into the `.github/workflows/*.yaml` files.
When `overlay_workflow_builder_generator generate workflows` is run, it reverts the following critical manual fixes:

1. **Incorrect G2 Ebuild Syntax Re-insertion:**
   - The generator writes `next_ebuild_file=$(g2 ebuild next-revision "${ebuild_dir}/${{ env.epn }}-${version}" -inspect "$tmp_ebuild_file")` and uses `if [ $? -eq 0 ]; then`.
   - This causes the workflow to exit `1` and fail because GitHub Actions uses `set -e`. The correct syntax is:
     ```bash
     if next_version=$(g2 ebuild next-revision --inspect "$tmp_ebuild_file" "${ebuild_dir}" "${version}"); then
         next_ebuild_file="${ebuild_dir}/${{ env.epn }}-${next_version}.ebuild"
     ```

2. **Generate Overlay Overwrites Profiles:**
   - The generator outputs:
     ```bash
     mkdir -p profiles
     echo "overlay_name" > profiles/repo_name
     echo "8" > profiles/eapi
     ```
   - This unconditionally overwrites `profiles/repo_name` and `profiles/eapi` each run, dirtying the Git directory and breaking `git pull --rebase`.
   - It should generate conditionally: `[ ! -f profiles/repo_name ] && echo "overlay_name" > profiles/repo_name`

3. **Linter Conditional Missing:**
   - The generator removes `if: steps.process_releases.outputs.generated_tag` from the `Lint output` step. This causes the linter to run and output noise even when no updates were found.

4. **Missing \${tag} vs v\${originalVersion} for Semantic Version Check Bypasses:**
   - The generator defaults to using `v${originalVersion}` instead of `${tag}` in `SRC_URI`, which breaks packages whose tags do not contain a `v` prefix.

5. **Concurrency Location Warning:**
   - The generator puts `concurrency:` under the `env:` block in some files instead of correctly nesting it at the root of the file or fixing its indentation.

## Proposed Solution:
Update the `overlay_workflow_builder_generator` template files to permanently embed these improvements, so manual regex patching via `sed` is no longer necessary after running `generate`.
