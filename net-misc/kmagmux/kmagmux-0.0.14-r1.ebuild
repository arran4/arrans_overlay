# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/net-misc-kmagmux-update.yaml
EAPI=8

inherit ecm

DESCRIPTION="Torrent file and Magnet link handler for programs/services"
HOMEPAGE="https://github.com/arran4/KMagMux"
SRC_URI="https://github.com/arran4/KMagMux/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

"
"
S="${WORKDIR}/KMagMux-${PV}"
