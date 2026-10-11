# GitHub CLI authentication for Portage live ebuilds

This package provides a **per-package** Portage environment file at
`/etc/portage/env/app-shells/a4sh`. Portage loads this location automatically
for `app-shells/a4sh`; no `/etc/portage/package.env` entry is required.
It works with the HTTPS `EGIT_REPO_URI` used by `git-r3` and does not alter
ebuilds, system-wide Git configuration, or Portage's sandbox.

## One-time authentication

As an administrator, log in as the **portage** user with the GitHub CLI:

```sh
sudo -u portage -H gh auth login --hostname github.com --git-protocol https
sudo -u portage -H git ls-remote https://github.com/arran4/shell.git HEAD
```

Use a dedicated **read-only, repository-scoped** credential where practical.
The ebuild never creates or stores a credential; it only references the
existing `gh` configuration at `/var/lib/portage/home/.config/gh`.
GitHub CLI may store credentials unencrypted if no secure store is available;
secure the directory and `hosts.yml` so only `portage` can read them. The
credential is readable to other processes running as `portage`, even though
the Git helper is only configured for `a4sh`.

If the portage account's home differs from `/var/lib/portage/home`, adjust
`GH_CONFIG_DIR` in the installed config with the normal Gentoo
`etc-update`/`dispatch-conf` process. Do not point `GIT_CONFIG_GLOBAL` to the
portage user's persistent `.gitconfig`: `git-r3` writes a per-checkout
`safe.directory` entry and must retain Portage's writable temporary Git
configuration.

## Other private live ebuilds

For a second private package, copy the installed `app-shells/a4sh`
configuration into the appropriately named
`/etc/portage/env/<category>/<package>` file, or create a reusable snippet in
`/etc/portage/env` and associate it using `/etc/portage/package.env`. Apply
the Git helper settings only to packages requiring authentication. Note that if `package.env` is a **file**, adding a directory
of the same name will conflict; never convert it automatically.

If `a4sh` already has a manual `package.env` entry pointing at another
`github-auth` environment file, that older entry is redundant after this
package is installed; review it before removing any locally maintained files.

Git's `GIT_CONFIG_COUNT` injection configures the `gh auth git-credential`
helper for HTTPS GitHub URLs without redirecting global Git config writes.
If another package environment already supplies `GIT_CONFIG_COUNT`, merge
the indexed entries rather than blindly overwriting that configuration.

## Verification and recovery

```sh
sudo emerge -1av app-shells/a4sh
```

Check `/var/tmp/portage/app-shells/a4sh-9999/temp/build.log` if a build fails.
This package doesn't disable sandboxing, enable terminal prompts, install
secrets, or grant access to arbitrary SSH keys. Unmerging the package removes
the installed environment file under normal Portage config-protection rules;
it does **not** revoke existing GitHub credentials. Revoke them separately in
GitHub CLI or GitHub settings if no longer required.
