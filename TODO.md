# TODO

- The `overlay_workflow_builder_generator` does not currently support specifying multiple binaries from the same archive for a single `Github Binary Release`. For example, `ast-grep` requires installing both `ast-grep` and `sg` from the same zip file. The workflow `.github/workflows/dev-util-ast-grep-bin-update.yaml` has been manually patched to support this. This feature should be added to the generator.
