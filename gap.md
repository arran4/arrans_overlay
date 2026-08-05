## Missing md5-cache checks
`g2 lint` emits a failure for `Missing md5-cache` despite the repository omitting caches intentionally. The pipeline currently suppresses this natively, but `g2 lint` should support properly ignoring these rules natively via a configuration flag in `metadata/qa-policy.conf`.

## Overlay Workflow Builder missing homepage configuration
The overlay workflow builder currently lacks support for properly injecting and propagating the Homepage configuration for GitHub binary releases based on `current.config`. It must be fixed upstream so it doesn't have to be manually tracked and preserved through `sed` modifications when upgrading ebuilds.
