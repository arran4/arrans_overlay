EAPI=8

DESCRIPTION="Twin - a Textmode WINdow environment"
HOMEPAGE="https://github.com/cosmos72/twin"
SRC_URI="https://github.com/cosmos72/twin/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE=""

BDEPEND="virtual/pkgconfig"
DEPEND="
    x11-libs/libX11
    x11-libs/libXft
    sys-libs/ncurses
    sys-libs/zlib
    sys-libs/gpm
"
RDEPEND="${DEPEND}"

src_configure() {
    econf
}

src_compile() {
    emake
}

src_install() {
    default
}
