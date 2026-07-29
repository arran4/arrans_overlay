# Overlay Workflow Builder Generator Update Gaps

1. **actions/checkout version fallback:** The newly generated workflows are using `actions/checkout@v7` which does not exist and fails workflows. They should use `v4` (or whatever the latest valid tag is).
2. **Loss of custom environment variables:** The generator removes `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` from the `env:` block.
3. **Removal of custom Install g2 step:** The generator removes the `Install g2` step using `arran4/g2-action@v1.2` entirely.
4. **git add metadata/md5-cache/ in workflows:** The generator adds `git add metadata/md5-cache/ || true` to the git commit steps. The cache generation is not enabled by default for everything and memory explicitly says `The repository no longer tracks the metadata/md5-cache or metadata/md5-dict directories in version control.`
