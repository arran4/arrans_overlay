# Feature Requests for `arrans_overlay_workflow_builder`

## 1. Missing Support for \${PV} variables in SRC_URI paths instead of explicit versions
The generator currently assumes that the path to release archives on GitHub uses explicit versions from the release. Some manual ebuilds used `https://github.com/owner/repo/releases/download/v\${originalVersion}/\${PV}`. After regeneration, `g2 manifest upsert-from-url` breaks because it produces `https://github.com/.../releases/download/\${tag}/\${version}` and similar paths which may fail for certain repositories like `pagefind-bin` and `hugo-bin`.

* **Potential Solution**: Introduce a workaround or configuration option like `ReleaseTagUsesPV` or allow `Binary` paths in `current.config` to dynamically map complex URLs instead of relying on the default generated pattern.

## 2. Manual Customizations Overwritten
Many workflows contained custom environment variables (e.g. `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24`), custom checkout actions (`actions/checkout@v4` vs `@v7`), or manually tweaked `g2 lint` commands. The generator blindly overwrites these, breaking the pipelines.

* **Potential Solution**: Support a mechanism to preserve manual workflow steps (like `g2 lint` overrides or custom `actions/checkout` tags) or include them in `current.config` using a `WorkflowOverride` configuration.

## 3. Flawed `g2 lint` step placement
The generator currently emits `action: 'lint . \${{ env.ecn }}/\${{ env.epn }}'` which is an unconditional step. Earlier manual versions fixed this to run only on condition: `if: steps.process_releases.outputs.generated_tag`. The generator lacks this conditional logic.

* **Potential Solution**: Add the `if: steps.process_releases.outputs.generated_tag` condition to the linting step globally within the tool's generation logic.

## 4. `g2 ebuild next-revision` Argument Ordering
The old workflows passed arguments to `g2 ebuild next-revision` in a different format than the generator now produces. The generator produces a format that may break manual scripts that depend on a specific output variable structure.

* **Potential Solution**: The tool should ensure its invocation of `g2 ebuild next-revision` conforms exactly to the latest `g2` standard without breaking existing pipeline state assignments.

## 5. Generator uses incorrect actions/checkout version
The generator outputs `uses: actions/checkout@v7`, but the latest version is `v4`.

* **Potential Solution**: Ensure the generator always references `@v4` or allows for customization of the version.

## 6. Generator does not support custom installation paths in `Binary` definitions
For `media-sound/go-playerctl-bin`, the binary is expected to be installed to `/opt/bin`. However, generator assumes `/usr/bin`.
* **Potential Solution**: Support a directive to set `InstallPath` for a binary, e.g. `InstallPath /opt/bin`.

## 7. Generator overrides RDEPEND values
In `.github/workflows/net-misc-rustdesk-appimage-update.yaml`, it generated `RDEPEND="sys-fs/fuse:0 sys-fs/fuse:0 sys-libs/glibc sys-libs/zlib"`, but original was `RDEPEND="sys-fs/fuse:0 sys-libs/glibc sys-libs/zlib"`.
* **Potential Solution**: Remove duplicates when generating `DEPEND` and `RDEPEND` arrays.
