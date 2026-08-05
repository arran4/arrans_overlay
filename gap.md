## Missing md5-cache checks (Fixed)
The missing md5-cache check feature has been resolved upstream in g2 v0.0.91!

## Overlay Workflow Builder missing homepage configuration
The overlay workflow builder currently lacks support for properly injecting and propagating the Homepage configuration for GitHub binary releases based on `current.config`. It must be fixed upstream so it doesn't have to be manually tracked and preserved through `sed` modifications when upgrading ebuilds.
