# nest overlay

[![Number of ebuilds: 736](https://img.shields.io/badge/ebuild-736-orange.svg)](https://img.shields.io/badge/ebuild-736-orange.svg)
[![GitHub repo size in bytes](https://img.shields.io/github/repo-size/arran4/arrans-overlay.svg)](https://img.shields.io/github/repo-size/arran4/arrans-overlay.svg)
[![gentoo overlay](https://img.shields.io/badge/gentoo-overlay-yellow)](https://github.com/gentoo-mirror/nest)

## How to use this overlay

For automatic install, you must have [`app-eselect/eselect-repository`](https://packages.gentoo.org/packages/app-eselect/eselect-repository)
or [`app-portage/layman`](https://packages.gentoo.org/packages/app-portage/layman) installed on your system for this to work.

### `eselect-repository`
```console
eselect repository enable arrans-overlay
```

### `layman`
```console
layman -fa arrans-overlay
```

For manual install, through [local overlay](https://wiki.gentoo.org/wiki/Creating_an_ebuild_repository), you should add this in `/etc/portage/repos.conf/arrans-overlay.conf`:

```console
[nest]
location = /var/db/repos/arrans-overlay
sync-type = git
sync-uri = https://github.com/gentoo-mirror/arrans-overlay.git
priority=9999
```

Afterwards, simply run `emerge --sync`, and Portage should seamlessly make all our ebuilds available.

