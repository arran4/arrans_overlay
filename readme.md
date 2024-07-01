# [Arran's overlay](https://github.com/arran4/arrans_overlay)

[![GitHub repo size in bytes](https://img.shields.io/github/repo-size/arran4/arrans-overlay.svg)](https://img.shields.io/github/repo-size/arran4/arrans-overlay.svg)
[![gentoo overlay](https://img.shields.io/badge/gentoo-overlay-yellow)](https://github.com/gentoo-mirror/arrans-overlay)

For more info on this checkout: https://wiki.gentoo.org/wiki/User:Arran4

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
[arrans-overlay]
location = /var/db/repos/arrans-overlay
sync-type = git
sync-uri = https://github.com/gentoo-mirror/arrans-overlay.git
```

Afterwards, simply run `emerge --sync`, and Portage should seamlessly make all our ebuilds available.

## Links

* [Merge status](https://gitweb.gentoo.org/report/repos.git/plain/arrans-overlay.txt)
* [Browse](https://gpo.zugaina.org/Overlays/arrans-overlay)
* [Upstream](https://github.com/gentoo-mirror/arrans-overlay)
