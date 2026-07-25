## arrans_overlay_workflow_builder gap

The `overlay_workflow_builder_generator` does not currently generate `HOMEPAGE` in the github-appimage generated workflows based on the `Homepage` configuration in `current.config`, which results in empty `HOMEPAGE=""` in generated ebuilds. Also for Github Binary Release, if the Homepage is defined, it is completely ignored resulting in missing HOMEPAGE in ebuilds.
Please add support for injecting the `HOMEPAGE` value defined in `current.config` directly into the generated ebuilds for both AppImage and Binary Release templates.
