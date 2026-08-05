## Feature Request: Ignore specific rules in g2 lint via flags

There is currently no open issue for this in the `arran4/g2` repository.

**Description:**
The `g2 lint` tool currently lacks a mechanism to disable specific checks (such as `PG0802` for `Missing md5-cache`) via command-line flags. While there is an `-only-tag` flag to restrict output to a specific tag, there is no corresponding `-ignore-tag` or `-disable-rule` flag to exclude them.

Additionally, as noted in the repository's known issues, the `ignore` directive in `metadata/qa-policy.conf` for `PG0802` does not correctly suppress the warning and still exits with code 255.

**Requested Features:**
1. Add an `-ignore-tag <tag>` or `-disable-rule <tag>` flag to `g2 lint` to explicitly exclude specific linting rules (e.g., `g2 lint -ignore-tag PG0802`).
2. Ensure that when rules are explicitly ignored (either via flags or `metadata/qa-policy.conf`), they do not trigger a non-zero exit code (e.g., 255) that breaks CI pipelines.

**Justification:**
In CI pipelines like GitHub Actions, certain checks (like cache generation) might be intentionally skipped or handled in a different step. Failing the entire `g2 lint` run because of these specific, non-critical missing files requires awkward shell workarounds (like piping to `grep -v` and managing exit codes) to keep the pipeline green while still catching legitimate errors.
