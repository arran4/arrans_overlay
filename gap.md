When generating or updating workflows, discard any generated workflows that contain only comment/whitespace changes, or that introduce unfixable breakages (regressions not resolvable via config). Document such upstream generator limitations and potential solutions in a tracked gap.md file.

Generator limitations:
1. 'Workaround Programs as Alternatives' injects architectures (e.g. amd64, arm64) directly into `REQUIRED_USE` and `metadata.xml` instead of checking the architecture of the system or relying on KEYWORDS. It also injects the alternative programs into `IUSE` twice (e.g. `extended extended`). This breaks packages like www-apps/hugo-bin by treating architectures as regular USE flags instead of relying on the target platform architecture, and causes duplicate `IUSE` flag warnings.

State as of v0.1.40:
- Architectures (e.g. amd64, arm, arm64) are no longer injected directly into `IUSE`.
- The alternative program string (e.g., 'extended') is injected into `IUSE` twice (e.g., `echo -n ' extended'; echo -n ' extended'`).
- Architectures are still explicitly injected into `REQUIRED_USE` (e.g., `extended? ( || ( amd64 arm64  ) ) `).
- Architectures are incorrectly added as USE flags in the `g2 metadata` command generation step (e.g., `--use-add "amd64:Enable amd64"`).
