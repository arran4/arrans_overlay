# Feature Requests / Bug Reports for overlay_workflow_builder_generator

## Issue: Revert of Important Fixes in Workflows

The `overlay_workflow_builder_generator` tool completely regenerates GitHub Actions workflow files and unconditionally overwrites them. This process consistently clobbers custom logic or manual fixes added to the `.github/workflows/*.yaml` files in this repository.

As a result, running `overlay_workflow_builder_generator generate workflows` reverts the following critical manual fixes:

### 1. Incorrect G2 Ebuild Syntax Re-insertion

**The Problem:**
The generator produces the following snippet for computing the next ebuild revision:
```bash
next_ebuild_file=$(g2 ebuild next-revision "${ebuild_dir}/${{ env.epn }}-${version}" -inspect "$tmp_ebuild_file")
if [ $? -eq 0 ]; then
    # ... success logic
```
This is an issue because GitHub Actions bash steps use `set -e` by default, meaning any failing command immediately exits the shell script. The `g2 ebuild next-revision` command returns an exit code of `1` when the contents match (indicating no changes). Because it exits `1`, the shell terminates before ever reaching the `if [ $? -eq 0 ]; then` condition. This crashes the CI/CD pipeline whenever an existing version matches.

**Minimal Reproducing Example:**
```bash
set -e
# Mock g2 command returning 1
next_ebuild_file=$(false)
# The script exits here; the following lines never execute.
if [ $? -eq 0 ]; then
    echo "Success"
fi
```

**Potential Solutions:**
- **Solution A (Preferred):** Modify the `overlay_workflow_builder_generator` template to wrap the assignment inside the `if` statement, which prevents `set -e` from triggering:
  ```bash
  if next_version=$(g2 ebuild next-revision --inspect "$tmp_ebuild_file" "${ebuild_dir}" "${version}"); then
      next_ebuild_file="${ebuild_dir}/${{ env.epn }}-${next_version}.ebuild"
  ```
- **Solution B:** Temporarily disable `set -e` around the command:
  ```bash
  set +e
  next_ebuild_file=$(g2 ebuild next-revision "${ebuild_dir}/${{ env.epn }}-${version}" -inspect "$tmp_ebuild_file")
  exit_code=$?
  set -e
  if [ $exit_code -eq 0 ]; then
  ```

---

### 2. Generate Overlay Overwrites Profiles

**The Problem:**
The generator produces a step that unconditionally writes to profile files:
```yaml
      - name: Generate Overlay
        run: |
          mkdir -p profiles
          echo "overlay_name" > profiles/repo_name
          echo "8" > profiles/eapi
```
This unconditionally modifies tracked repository files (`profiles/repo_name` and `profiles/eapi`) on every run. When these files are dirtied locally, a subsequent Git rebase inside the GitHub Action fails with uncommitted changes, halting the release pipeline.

**Minimal Reproducing Example:**
```bash
git checkout main
echo "overlay_name" > profiles/repo_name
git rebase origin/main
# Fails with: error: Cannot rebase: Your index contains uncommitted changes.
```

**Potential Solutions:**
- **Solution A:** Update the generator to only create these files if they don't already exist.
  ```bash
  mkdir -p profiles
  [ ! -f profiles/repo_name ] && echo "overlay_name" > profiles/repo_name
  [ ! -f profiles/eapi ] && echo "8" > profiles/eapi
  ```
- **Solution B:** Output the repository name dynamically rather than a hardcoded "overlay_name":
  ```bash
  [ ! -f profiles/repo_name ] && echo "${{ env.github_repo }}" > profiles/repo_name
  ```

---

### 3. Linter Conditional Missing

**The Problem:**
The generator produces a `Lint output` step without a condition to check if any new ebuilds were actually generated.
```yaml
      - name: Lint output
        uses: arran4/g2-action@v1.2
        with:
          mode: 'run'
          action: 'lint . ${{ env.ecn }}/${{ env.epn }}'
```
This causes the linter to run on every scheduled CI check, even when no new releases exist. This generates noise in the CI logs and wastes execution time analyzing unchanged code.

**Minimal Reproducing Example:**
When no new releases are published upstream, the `process_releases` step completes with zero modifications. The subsequent `Lint output` step still runs, analyzing the entire overlay directory structure unnecessarily.

**Potential Solutions:**
- **Solution A:** Update the generator template to include the conditional from the manual fixes:
  ```yaml
      - name: Lint output
        if: steps.process_releases.outputs.generated_tag
        uses: arran4/g2-action@v1.2
        with: ...
  ```

---

### 4. Missing \${tag} vs v\${originalVersion} for Semantic Version Check Bypasses

**The Problem:**
By default, the generator constructs `SRC_URI` URLs using `v${originalVersion}`:
```bash
echo "	amd64? (  https://github.com/${{ env.github_owner }}/${{ env.github_repo }}/releases/download/v${originalVersion}/\${PV} -> ... )  "
```
This breaks packages whose release tags lack a `v` prefix (e.g., `1.1.12` instead of `v1.1.12`). While the `current.config` allows specifying `Workaround Semantic Version Without V`, the generator still hardcodes `v${originalVersion}` instead of dynamically using the exact `\${tag}` variable.

**Minimal Reproducing Example:**
For a repository with tag `1.0.0`:
`originalVersion` evaluates to `1.0.0`.
The downloaded URL becomes `.../download/v1.0.0/...` which 404s.

**Potential Solutions:**
- **Solution A:** Change the generator template to use the `\${tag}` variable for the download URL:
  ```bash
  echo "	amd64? (  https://github.com/${{ env.github_owner }}/${{ env.github_repo }}/releases/download/${tag}/\${PV} -> ... )  "
  ```

---

### 5. Concurrency Location Warning

**The Problem:**
The generator places the `concurrency:` block directly inside or mixed with the `env:` block in the generated yaml files, or incorrectly indented, which leads to YAML mapping errors.
```yaml
env:
  ecn: app-admin
  # ...
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: false
```
While sometimes syntactically valid at the root level, `overlay_workflow_builder_generator` has been known to indent it incorrectly under `env:` or place it in unsupported locations.

**Minimal Reproducing Example:**
Running `actionlint` on an incorrectly generated file yields:
`syntax error: mapping key "concurrency" is already defined`

**Potential Solutions:**
- **Solution A:** Ensure the generator correctly emits the `concurrency` block strictly at the root level of the YAML document, formatted clearly before the `jobs:` block.
