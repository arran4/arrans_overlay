When generating or updating workflows, discard any generated workflows that contain only comment/whitespace changes, or that introduce unfixable breakages (regressions not resolvable via config). Document such upstream generator limitations and potential solutions in a tracked gap.md file.

Generator limitations:
1. 'Workaround Programs as Alternatives' injects the alternative programs into `IUSE` twice (e.g. `extended extended`). This causes duplicate `IUSE` flag warnings.

State as of v0.1.40:
- The alternative program string (e.g., 'extended') is injected into `IUSE` twice (e.g., `echo -n ' extended'; echo -n ' extended'`).
