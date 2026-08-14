When generating or updating workflows, discard any generated workflows that contain only comment/whitespace changes, or that introduce unfixable breakages (regressions not resolvable via config). Document such upstream generator limitations and potential solutions in a tracked gap.md file.

Generator limitations:
1. 'Workaround Programs as Alternatives' injects architectures (e.g. amd64, arm64) directly into IUSE and REQUIRED_USE instead of checking the architecture of the system or relying on KEYWORDS. This breaks packages like www-apps/hugo-bin by treating architectures as regular USE flags instead of relying on the target platform architecture.
