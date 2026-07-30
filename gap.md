# Feedback and Feature Requests for overlay_workflow_builder_generator v0.1.31

I have encountered a few issues while using version 0.1.31 of `overlay_workflow_builder_generator` and I wanted to file these feature requests/issues to help improve the tool.

## Issues with generated `.github/workflows/*-update.yaml` workflows
1.  **Missing `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24`**: The generator no longer outputs the `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` environment variable in the generated workflows, which was present in previously generated files (e.g. from version 0.1.28). This causes issues with certain runners.
2.  **Invalid `actions/checkout` version**: The generated workflows use `uses: actions/checkout@v7`, which is an invalid version of the action (the latest major version is `v4`). It should use `uses: actions/checkout@v4` instead.
3.  **Invalid `g2 ebuild next-revision` syntax**: The generator changed the `g2 ebuild next-revision` command call. It used to be `g2 ebuild next-revision --inspect "$tmp_ebuild_file" "${ebuild_dir}" "${version}"` which outputs the `next_version` (e.g., `-r1`). It was changed to `g2 ebuild next-revision "${ebuild_dir}/${{ env.epn }}-${version}" -inspect "$tmp_ebuild_file"` which assigns to `next_ebuild_file` directly. This change uses an invalid flag structure.
4.  **Global `lint .`**: The linting step was changed from `action: 'lint ${{ env.ecn }}/${{ env.epn }}'` to `action: 'lint . ${{ env.ecn }}/${{ env.epn }}'`. Running a global lint (`lint .`) on every update workflow may take too long or trigger errors on unrelated packages. Furthermore, the `if: steps.process_releases.outputs.generated_tag` condition was removed.
5.  **`metadata/md5-cache/` tracking**: The generator adds `git add metadata/md5-cache/ || true` to the commit step. Since `metadata/md5-cache` is no longer tracked in version control, this line is incorrect and can lead to unexpected behavior.

Would it be possible to address these regressions in a future version of `overlay_workflow_builder_generator`?
