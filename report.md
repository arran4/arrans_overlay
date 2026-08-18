# Gentoo USE Flags Report
Based on [Gentoo Development Guide: USE Flags](https://devmanual.gentoo.org/general-concepts/use-flags/index.html)

## 1. Local and Global USE flags
Found 23 unique USE flags in 116 ebuilds.
USE Flags:
- alsa
- amd64
- android
- arm
- arm64
- bash
- cups
- debug
- doc
- extended
- fish
- glibc
- headless-awt
- le
- loong64
- man
- rocm
- sdl
- selinux
- source
- static-libs
- systemd
- zsh

## 2. Architecture flags in IUSE
According to the manual, architecture keywords (like x86, amd64, arm) should NOT be in IUSE. They are handled implicitly by Portage via KEYWORDS.
- **Violation**: Found arch flag `amd64` in `./app-misc/superfile-bin/superfile-bin-1.6.0-r1.ebuild`
- **Violation**: Found arch flag `arm64` in `./app-misc/superfile-bin/superfile-bin-1.6.0-r1.ebuild`
- **Violation**: Found arch flag `amd64` in `./www-apps/hugo-bin/hugo-bin-0.165.0.ebuild`
- **Violation**: Found arch flag `arm` in `./www-apps/hugo-bin/hugo-bin-0.165.0.ebuild`
- **Violation**: Found arch flag `arm64` in `./www-apps/hugo-bin/hugo-bin-0.165.0.ebuild`

## 3. noblah USE flags
Avoid noblah style USE flags. These break use.mask and cause complications.
No obvious `noblah` USE flags found.

## 4. IUSE Defaults
Add + or - before the name of the use flag in IUSE to turn it on or off by default.
IUSE defaults should be used sparingly.
Note: Adding - before a flag in IUSE is pretty much useless.

- Found default flag `+systemd` in `./app-misc/ollama-bin/ollama-bin-0.32.14.ebuild`
- Found default flag `-rocm` in `./app-misc/ollama-bin/ollama-bin-0.32.14.ebuild`
  - **Warning**: Using `-` prefix on `-rocm` is generally useless.

## 5. USE flag descriptions
All USE flags must be described in either use.desc in the profiles/ directory or metadata.xml in the package's directory.

- **Violation**: USE flag `rocm` is used in `./app-misc/ollama-bin/ollama-bin-0.32.14.ebuild` but not described in `./app-misc/ollama-bin/metadata.xml`
- **Violation**: USE flag `headless-awt` is used in `./dev-java/corretto-bin/corretto-bin-25.0.4.7.1.ebuild` but not described in `./dev-java/corretto-bin/metadata.xml`
- **Violation**: USE flag `source` is used in `./dev-java/corretto-bin/corretto-bin-25.0.4.7.1.ebuild` but not described in `./dev-java/corretto-bin/metadata.xml`
- **Violation**: USE flag `man` is used in `./dev-go/goreleaser-bin/goreleaser-bin-2.17.1.ebuild` but not described in `./dev-go/goreleaser-bin/metadata.xml`

## 6. Conflicting USE flags and REQUIRED_USE
Occasionally, ebuilds will have conflicting USE flags for functionality.
The ebuild can specify allowed USE flag combinations with REQUIRED_USE.

- Found REQUIRED_USE=`extended? ( || ( amd64 arm64  ) )` in `./www-apps/hugo-bin/hugo-bin-0.165.0.ebuild`
- Found REQUIRED_USE=`android? ( || ( arm64  ) ) glibc? ( || ( amd64  ) ) le? ( || ( ppc64  ) ) loong64? ( || ( amd64  ) )` in `./app-admin/chezmoi-bin/chezmoi-bin-2.71.1.ebuild`
- Found REQUIRED_USE=`${PYTHON_REQUIRED_USE}` in `./dev-embedded/esp-idf/esp-idf-6.0.2-r1.ebuild`
## 7. Actionable Recommendations

Based on the violations found, here are the actionable steps to fix them:

**Fixing Architecture Flags in IUSE:**
Architecture keywords are handled implicitly by Portage via `KEYWORDS` and should be removed from `IUSE`. Note: Be careful as some of these may be injected by generator bugs (e.g. `overlay_workflow_builder_generator`), requiring manual workflow patching or `.config` changes.
1. `app-misc/superfile-bin`: Remove `amd64` and `arm64` from `IUSE` in `superfile-bin-1.6.0-r1.ebuild`.
2. `www-apps/hugo-bin`: Remove `amd64`, `arm`, and `arm64` from `IUSE` in `hugo-bin-0.165.0.ebuild`.

**Fixing IUSE Defaults:**
1. `app-misc/ollama-bin`: Remove the `-` prefix from `-rocm` in `IUSE`, as it is useless according to the devmanual.

**Fixing Missing USE Flag Descriptions:**
If these flags are not defined globally in the gentoo main tree `use.desc`, they must be documented locally in the `metadata.xml` of the respective package.
1. `app-misc/ollama-bin`: Add `<flag name="rocm">...</flag>` description to `metadata.xml`.
2. `dev-java/corretto-bin`: Add `<flag name="headless-awt">...</flag>` and `<flag name="source">...</flag>` descriptions to `metadata.xml`.
3. `dev-go/goreleaser-bin`: Add `<flag name="man">...</flag>` description to `metadata.xml`.
