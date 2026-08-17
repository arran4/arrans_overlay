# Gentoo Tree General Concepts Review Report

## Overview
This report evaluates the current state of the `arrans_overlay` Gentoo repository against the guidelines specified in the [Gentoo Development Manual: The Gentoo repository](https://devmanual.gentoo.org/general-concepts/tree/index.html).

## Findings & Violations

### 1. Missing Category Metadata
According to the manual, each category directory should contain a `metadata.xml` file describing the category.
The following categories are currently missing their `metadata.xml` files:
- `acct-group`
- `acct-user`
- `app-admin`
- `app-dicts`
- `app-emulation`
- `app-misc`
- `app-pda`
- `app-portage`
- `app-text`
- `dev-embedded`
- `dev-go`
- `dev-java`
- `dev-lang`
- `dev-libs`
- `dev-python`
- `dev-util`
- `dev-vcs`
- `games-util`
- `media-fonts`
- `media-sound`
- `media-video`
- `net-im`
- `net-misc`
- `sys-apps`
- `www-apps`
- `www-misc`

### 2. Missing/Empty Root Manifest
The root level contains a `Manifest` file which appears to be empty.

### 3. File Naming Rules
The manual states: *Things that do not belong in the tree: Files whose name contains characters outside [A-Za-z0-9._+-], Files whose name starts with a dot, a hyphen, or a plus sign.*
There are dotfiles in the root of the tree, which are allowed by git (`.gitignore`, `.editorconfig`) but technically violate the strict Gentoo tree character rules. This is acceptable for an overlay, but worth noting.

### 4. Non-text Files
The manual explicitly states *Non-text files* do not belong in the tree. No significant non-text files or large patches were found directly violating this, outside of standard overlay infrastructure.

## Proposed Easy Wins

1. **Create Category Metadata:** Create a `metadata.xml` file for every category missing one. This requires creating simple XML files with a `<catmetadata>` block and a brief `<longdescription>`.
2. **Clean up empty root Manifest:** If the empty `Manifest` at the root of the repository is not needed or generated incorrectly, it can be deleted, as manifest files are typically generated per-package.
