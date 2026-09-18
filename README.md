# arrans_overlay

Personal Gentoo overlay for packages and packaging experiments maintained by Arran Ubels.

## Repository dependencies

This overlay is layered on top of the Gentoo repository and other upstream overlays. The authoritative repository metadata is `metadata/layout.conf`, which currently declares:

```text
masters = gentoo guru hyproverlay
```

Accordingly, **GURU is an upstream dependency of this overlay**, not a peer to duplicate locally. Systems and CI using `arrans_overlay` should make the Gentoo, GURU, and hyproverlay repositories available as its declared masters.

## Packaging policy

Before adding or vendoring a dependency in `arrans_overlay`, first check whether an appropriate package already exists in Gentoo or GURU. Prefer depending on those upstream packages when they provide the required ABI, features, and source semantics.

Vendoring or carrying an overlay-local copy is appropriate only when the upstream package cannot satisfy the package's actual requirements, for example because an application requires a specific patched or pinned source snapshot that is not substitutable with the system package. Such exceptions should be documented in the ebuild or accompanying maintainer tooling.

Packages that become suitably available in Gentoo or GURU should normally migrate there rather than remain duplicated in this overlay.

## Maintainer guidance

See [`AGENTS.md`](AGENTS.md) for repository maintenance, generation, testing, versioning, and dependency-selection rules.
