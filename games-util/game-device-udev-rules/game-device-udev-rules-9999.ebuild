# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 udev

DESCRIPTION="Udev rules for supported game controllers"
HOMEPAGE="https://codeberg.org/fabiscafe/game-devices-udev"
EGIT_REPO_URI="https://codeberg.org/fabiscafe/game-devices-udev.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

DEPEND=""
RDEPEND="virtual/udev"

src_install() {
	udev_dorules *.rules
}

pkg_postinst() {
	udev_reload
}
