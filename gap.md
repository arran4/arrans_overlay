# Gap Documentation

## Workflow Concurrency Generator Issue

The `arrans_overlay_workflow_builder` generates a generic `group: ci-${{ github.ref }}` concurrency group.
Because GitHub applies concurrency cancellation by group string, unrelated workflows running on `main`
may share the identical concurrency group `ci-refs/heads/main` and unexpectedly cancel each other.

To fix this, the generator needs an upstream fix to incorporate the `github.workflow` or the package name
into the concurrency group, such as `group: ${{ github.workflow }}-${{ github.ref }}`.
The actual defect originates in `arran4/arrans_overlay_workflow_builder`, specifically its `templates/github-*.tmpl` and `templates/web-*.tmpl` files.

Currently, we manually modified all manually maintained workflow files to use `group: ${{ github.workflow }}-${{ github.ref }}`.
Generated files continue to use `group: ci-${{ github.ref }}`. The regression test will explicitly inventory these remaining generator issues and block the repository from passing `test_workflow_concurrency.sh` until the upstream generator is fixed and files are regenerated from `current.config`. Manual edits to generated files are discouraged to avoid generated-file drift.
