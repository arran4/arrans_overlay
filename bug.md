# Workflow Builder Issues

The `overlay_workflow_builder_generator` generates incorrect output in two areas:

1. **`g2 ebuild next-revision` syntax:**
   The generated workflows use an invalid syntax for `g2 ebuild next-revision`.
   Incorrect: `next_ebuild_file=$(g2 ebuild next-revision "${ebuild_dir}/${{ env.epn }}-${version}" -inspect "$tmp_ebuild_file")`
   Correct: `next_version=$(g2 ebuild next-revision --inspect "$tmp_ebuild_file" "${ebuild_dir}" "${version}")`
   (Then construct the path with `next_ebuild_file="${ebuild_dir}/${{ env.epn }}-${next_version}.ebuild"`)

2. **Linting md5-cache configuration:**
   The workflow builder expects md5-cache to exist or be generated, but it has now been configured off properly in the overlay via `cache-formats = ` in `metadata/layout.conf`. The workflow builder should be updated to adhere to this overlay configuration when generating lint steps, rather than assuming md5-cache is present.
