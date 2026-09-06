# Copyright 2026 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Quickly create and run macOS and Linux virtual machines"
HOMEPAGE="https://github.com/quickemu-project/quickemu"
PUB="github.com/quickemu-project/quickemu/archive/refs/tags"
SRC_URI="https://${PUB}/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=app-emulation/qemu-6.0.0 app-arch/unzip app-cdr/cdrtools"
RDEPEND+=" app-emulation/spice app-misc/jq dev-python/python-exec net-misc/curl"
RDEPEND+=" net-misc/socat net-misc/wget net-misc/zsync sys-apps/coreutils"
RDEPEND+=" sys-apps/pciutils sys-apps/usbutils sys-apps/util-linux"
RDEPEND+=" sys-process/procps x11-apps/mesa-progs x11-apps/xrandr"
RDEPEND+=" x11-misc/xdg-user-dirs"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack "${P}.tar.gz"
}

src_install() {
	dobin "quickemu-${PV}/quickemu"
	dobin "quickemu-${PV}/quickget"
	dobin "quickemu-${PV}/quickreport"
	dobin "quickemu-${PV}/chunkcheck"
}
