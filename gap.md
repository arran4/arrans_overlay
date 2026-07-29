# Gaps and Issues in Overlay Workflow Builder Generator v0.1.27

## 1. Unwanted inclusion of `metadata/md5-cache` in git add
The generated workflow includes `git add metadata/md5-cache/ || true` in the commit step. The repository no longer tracks the `metadata/md5-cache` or `metadata/md5-dict` directories in version control. Therefore, the tool should not automatically stage and commit `metadata/md5-cache/`. Tracked in: https://github.com/arran4/arrans_overlay_workflow_builder/issues/72

## 2. Variable regression in `superfile-bin`
In `app-misc/superfile-bin-update.yaml`, the generator emitted `${TAG}` inside the `Binary` path string (e.g., `Binary amd64=>superfile-linux-amd64.tar.gz > superfile > superfile`), but bash evaluates `${TAG}` as empty. The manual edit used `${tag}` which resolves to the correctly extracted version in the bash loop.
- **What:** The `Binary` directive processing fails to correctly pass through the lower-case `${tag}` variable.
- **Why:** `current.config` was updated to use `${TAG}`, but the generator doesn't substitute it with the bash-safe variable name during the loop emission.
- **Solution:** Standardize and explicitly translate `${TAG}` in config files to the `${tag}` variable used inside the bash loop.
Tracked in: https://github.com/arran4/arrans_overlay_workflow_builder/issues/73

## 3. Workarounds and manual edits overwrite
The tool overwrites manual changes in the generated files. This causes severe regressions. Here are specific examples of what is broken, why it was there, and how we might fix it systemically:

- **`app-misc/gocdm-bin`**:
  - **What:** Has a custom `pkg_postinst` block that warns the user they must add their user to the `video` group.
  - **Why:** The application requires specific system group permissions to function that the generic `bin` installation does not handle.
  - **Solution:** Add a config directive like `EbuildPostinst` or `EbuildInjectFile` that allows appending specific script content to the ebuild file.

- **`dev-util/codex-bin`**:
  - **What:** Uses a custom Bash snippet `version="${tag#rust-v}"` to strip the prefix instead of the default `v`.
  - **Why:** The upstream repository uses an unusual tag format (`rust-v0.1.0`) that isn't cleanly handled by standard version stripping.
  - **Solution:** Expand the `Workaround Tag Prefix => prefix-` to support stripping from the generated Gentoo PV logic.

- **`media-sound/go-playerctl-bin`**:
  - **What:** Contains a custom `dosym /usr/bin/go-playerctl-bin /usr/bin/go-playerctl` in `src_install`.
  - **Why:** The binary is packaged with a name that users don't typically want to type out in the CLI, so a symlink was provided.
  - **Solution:** Introduce a config directive `Symlink <target> <destination>` to automatically emit `dosym` commands.

- **`app-misc/flutter-jules-bin`**:
  - **What:** Has custom `sed` statements in `src_install` and manually explicitly defines an accurate `LICENSE` field.
  - **Why:** Desktop files needed path adjustments for the icon and exec. The generator emitted `unknown` for the license.
  - **Solution:** Support specifying the `License` field properly (already requested) and add an `IconPatch` or `ExecPatch` directive for `.desktop` files.

- **`www-misc/which_browser`**:
  - **What:** Heavy modifications including `src_prepare` with `patchelf` execution to replace missing dependencies, custom extraction of build suffixes `+44`, and copying `/usr/` paths.
  - **Why:** This is a `.deb` package masquerading as a simple binary, requiring specialized unpacking and `.so` library path fixing.
  - **Solution:** This package is too complex for the current generic generator. The generator should perhaps have an `Ignore` flag in `current.config` to prevent it from ever attempting to regenerate specific workflows, or rely on injection files.

## Feature Requests

### 1. Mechanism for Preserving Custom Ebuild Bash Logic
**Issue:** The generator completely replaces the entire `.github/workflows/*-update.yaml` file on generation. Many workflows have critical custom bash scripts injected into the ebuild `cat <<EOT` block.
**Feature Request:** Instead of inline workarounds for every single edge case, update the config to point to injection files. For example, a directive like `EbuildInclude src_install => patches/flutter-jules-install.sh`. The tool would read the external file and inject its contents directly into the generated `cat <<EOT` block at the appropriate section. This keeps the config clean and fully supports arbitrarily complex ebuild logic (like `patchelf` or `dosym`) without losing it on regeneration.

### 2. Full Configuration Property Pass-through
**Issue:** The generator currently hardcodes strings or misses parsing certain metadata fields specified in the config or originally managed manually. For example, it defaults to `--m "gentoo@arran4.com:Arran Ubels:person"` in the `g2 metadata` command, and it doesn't correctly export `HOMEPAGE` for AppImages if not fully supported. This is tracked in: https://github.com/arran4/arrans_overlay_workflow_builder/issues/69
**Feature Request:** Support comprehensive property assignments in `current.config` such as `MaintainerEmail`, `MaintainerName`, and ensure that `HOMEPAGE` and `LICENSE` properties correctly flow into all generated templates without defaulting to placeholders like `unknown`.

### 3. Bash Context Evaluation Handling for Binary Paths
**Issue:** The generator writes `${TAG}` instead of `${tag}` in the `SRC_URI` and manifest download urls strings if defined in the config. Because `cat <<EOT` natively disables bash evaluation, and `${TAG}` is not explicitly declared inside the Bash workflow loop (`${tag}` is), the evaluation resolves to an empty string breaking the manifest upserter.
**Feature Request:** Standardize and explicitly document internal variable mapping (`${tag}` vs `${TAG}`) for the `Binary` directive in `current.config`, and ensure the tool emits correct shell variables matching the Bash environment variable scope loop declarations. Tracked in: https://github.com/arran4/arrans_overlay_workflow_builder/issues/74
