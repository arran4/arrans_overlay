# Requested Feature for g2

Please add a feature to clean up `Manifest` files by removing unused entries (such as unused `DIST` files and missing `EBUILD` files) for a package.

For example, a command like `g2 manifest clean <package-dir>` that analyzes the remaining ebuilds in a package directory and removes `DIST` entries that are no longer referenced by any of the existing ebuilds, as well as any `EBUILD` entries that no longer exist.