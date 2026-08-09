# Bug Report: `g2 lint` is overly strict regarding `md5-cache` (Rule PG0802)

**Related Issue:** [arran4/g2#415](https://github.com/arran4/g2/issues/415)

## Describe the Bug
The `g2 lint` command enforces rule PG0802 (`Missing md5-cache`) by default. In many modern or lightweight Gentoo overlays, the `md5-cache` directory is not tracked in version control, and cache generation might be completely disabled or managed by standard Portage tools rather than committed.

Currently, if the repository does not explicitly configure `cache-formats = ` in `metadata/layout.conf`, `g2 lint` throws a fatal warning, breaking CI pipelines. This forces users to configure their overlays around `g2`'s strict defaults, rather than `g2` gracefully handling a missing cache directory.

## Steps to Reproduce
1. Create a minimal Gentoo overlay without a `metadata/layout.conf` file (or one without `cache-formats` defined).
2. Create an ebuild package.
3. Run `g2 lint .` without generating an `md5-cache`.
4. Observe the warning: `[Warning] Missing md5-cache for ebuild ...` which returns exit code 255.

## Expected Behavior
`g2 lint` should intelligently check if the `metadata/md5-cache` directory actually exists in the repository before enforcing rule PG0802.
If the directory does not exist, `g2 lint` should assume cache is not being tracked and either downgrade this to an informational log or dynamically disable the rule by default, unless the user passes a flag to explicitly strictly enforce cache checks.
