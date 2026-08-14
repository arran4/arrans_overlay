# Workflow Builder Support Gap Report

This document outlines limitations and missing features in the `overlay_workflow_builder_generator` related to updating `which_browser` from `which-browser-site.pages.dev` and handling Flutter-style version strings.

## Issue 1: Missing Support for Cloudflare Pages Deployments

**Description:**
The `overlay_workflow_builder_generator` currently lacks native support for fetching and evaluating updates from sites hosted on Cloudflare Pages (e.g., `https://which-browser-site.pages.dev/`). It primarily supports parsing standard release channels like GitHub Releases, GitLab Releases, or specific known archive patterns.

**Details:**
- The generator cannot automatically poll `https://which-browser-site.pages.dev/` to determine the latest available version.
- As a result, the `current.config` configuration for `which_browser` cannot properly trigger automated GitHub Actions workflows to scrape for new `.deb` files from this host.

**Required Features (Feature Request):**
1. Implement a generic HTTP scraping module or a specific Cloudflare Pages index parser within `overlay_workflow_builder_generator`.
2. Allow defining a `Regex` or `XPath` in `current.config` to extract the latest version string from custom HTML/JSON indexes hosted on `.pages.dev` domains.

## Issue 2: Ebuild Parser Failure with Complex Bash Parameter Expansion and Flutter Versioning

**Description:**
The `g2` static ebuild parser fails to correctly interpret complex Bash parameter expansions (like `${PV%.*}`) within the `SRC_URI` definition when the version string contains a `+` symbol (common in Flutter releases, e.g., `0.2.6.44-r1` resolving to `0.2.6+44`).

**Details:**
- When an ebuild uses dynamic string manipulation to build the `SRC_URI`:
  ```bash
  # Example that fails in g2 static parsing:
  MY_PV_NO_REV="${PV%%-r*}"
  MY_BASE_PV="${MY_PV_NO_REV%.*}"
  MY_BUILD_SUFFIX="${MY_PV_NO_REV##*.}"
  MY_DEB_ARCHIVE="which_browser-${MY_BASE_PV}+${MY_BUILD_SUFFIX}-linux.deb"
  SRC_URI="https://which-browser-site.pages.dev/downloads/v${MY_BASE_PV}/${MY_DEB_ARCHIVE}"
  ```
- The `g2 lint` tool evaluates the `SRC_URI` as a raw, un-interpolated string (e.g., `which_browser-${PV%.*}+${PV-linux.deb`).
- This causes the linter to throw a false positive `MissingManifest` error (or `Manifest entry for unused DIST file`), as the evaluated filename in the `SRC_URI` does not match the actual `.deb` filename in the `Manifest`.
- To bypass this bug, maintainers are forced to hardcode the version string directly into the ebuild's `SRC_URI` and `src_unpack` phases.

**Required Fixes (Bug Report):**
1. Enhance the `g2` static ebuild parser (used during linting and manifest generation) to fully support standard bash parameter expansions (e.g., `${var%.*}`, `${var##*.}`) and functions like `ver_cut` during string evaluation.
2. Specifically ensure that the parser correctly handles version strings containing `+` symbols, as this format is prevalent in Flutter-based applications.
