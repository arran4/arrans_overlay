# Copyright 2026 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Quickly create and run macOS and Linux virtual machines"
HOMEPAGE="https://github.com/quickemu-project/quickemu"
PUB="github.com/quickemu-project/quickemu/archive/refs/tags"
SRC_URI="https://${PUB}/${PV}.tar.gz -> ${P}-v${PV}.tar.gz"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="app-arch/unzip app-cdr/genisoimage app-emulation/qemu"
RDEPEND+=" app-emulation/spice app-misc/jq net-misc/curl net-misc/socat"
RDEPEND+=" net-misc/wget sys-apps/coreutils sys-apps/pciutils"
RDEPEND+=" sys-apps/usbutils sys-apps/util-linux sys-process/procps"
RDEPEND+=" x11-apps/xrandr"

src_unpack() {
	unpack "${P}-v${PV}.tar.gz"
}

src_install() {
	dobin "quickemu-${PV}/quickemu"
	dobin "quickemu-${PV}/quickget"
	dobin "quickemu-${PV}/quickreport"
	dobin "quickemu-${PV}/chunkcheck"
}
