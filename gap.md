# Gap Documentation

## Workflow Concurrency Generator Issue

The `arrans_overlay_workflow_builder` generates a generic `group: ci-${{ github.ref }}` concurrency group.
Because GitHub applies concurrency cancellation by group string, unrelated workflows running on `main`
may share the identical concurrency group `ci-refs/heads/main` and unexpectedly cancel each other.

To fix this, the generator needs an upstream fix to incorporate the `github.workflow` or the package name
into the concurrency group, such as `group: ${{ github.workflow }}-${{ github.ref }}`.

Currently, we manually modified all manually maintained workflow files to use `group: ${{ github.workflow }}-${{ github.ref }}`.
Generated files continue to use `group: ci-${{ github.ref }}` and are skipped in the tests until the generator is fixed upstream. Manual edits to generated files are discouraged to avoid generated-file drift.
