## `set -e` failure in generated `g2 ebuild next-revision` logic

The `overlay_workflow_builder_generator` generates the following bash code snippet in `*-update.yaml` GitHub Actions workflows:

```bash
next_version=$(g2 ebuild next-revision --inspect "$tmp_ebuild_file" "${ebuild_dir}" "${version}")
if [ $? -eq 0 ]; then
    next_ebuild_file="${ebuild_dir}/${{ env.epn }}-${next_version}.ebuild"
    # ...
```

Because GitHub Actions `run` steps execute with `set -e` by default, when the ebuild contents match the highest existing revision (ignoring comments/whitespace), `g2 ebuild next-revision --inspect` exits with code `1`. This causes the workflow step to immediately terminate in a failure state before it reaches `if [ $? -eq 0 ]; then`.

To fix this, the generated logic should instead evaluate the assignment directly within an `if` statement context, which natively suppresses the `set -e` early exit on failure:

```bash
if next_version=$(g2 ebuild next-revision --inspect "$tmp_ebuild_file" "${ebuild_dir}" "${version}"); then
    next_ebuild_file="${ebuild_dir}/${{ env.epn }}-${next_version}.ebuild"
    # ...
```
