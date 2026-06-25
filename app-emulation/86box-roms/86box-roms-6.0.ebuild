# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-emulation-86box-roms-update.yaml
EAPI=8
DESCRIPTION="ROMs for the 86Box emulator."
HOMEPAGE="https://github.com/86Box/roms/"
IUSE=""
SRC_URI="https://github.com/86Box/roms/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="proprietary"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}/roms-${PV}"
RESTRICT="binchecks strip"

src_install() {
    insinto "/usr/share/86box-roms"
    doins -r "${S}/floppy"
    doins -r "${S}/hdd"
    doins -r "${S}/machines"
    doins -r "${S}/network"
    doins -r "${S}/printer"
    doins -r "${S}/scsi"
    doins -r "${S}/sound"
    doins -r "${S}/video"
    dodoc "README.md"
}

