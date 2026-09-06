# Copyright 2026 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Quickly create and run Windows, macOS and Linux virtual machines"
HOMEPAGE="https://github.com/quickemu-project/quickemu"
PUB="github.com/quickemu-project/quickemu/archive/refs/tags"
SRC_URI="https://${PUB}/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/quickemu-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=app-emulation/qemu-6.0.0[spice] app-arch/unzip app-cdr/cdrtools"
RDEPEND+=" app-crypt/swtpm app-misc/jq dev-lang/python net-misc/curl"
RDEPEND+=" net-misc/socat net-misc/spice-gtk[gtk3] net-misc/wget net-misc/zsync"
RDEPEND+=" sys-apps/coreutils sys-apps/pciutils sys-apps/usbutils"
RDEPEND+=" sys-apps/util-linux sys-process/procps x11-apps/mesa-progs"
RDEPEND+=" x11-apps/xrandr x11-misc/xdg-user-dirs"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack "${P}.tar.gz"
}

src_install() {
	dobin quickemu
	dobin quickget
	dobin quickreport
	dobin chunkcheck
}
