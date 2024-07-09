EAPI=8

DESCRIPTION="Roms for 86box"
HOMEPAGE="https://github.com/86Box/roms/"
SRC_URI="https://github.com/86Box/roms/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="proprietary"
SLOT="0"
KEYWORDS="amd64"
S="${WORKDIR}/roms-${PV}"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

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
