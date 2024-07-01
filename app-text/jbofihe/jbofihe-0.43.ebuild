# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-text-jbofihe-update.yaml
EAPI=8
DESCRIPTION="The de facto standard parser and glosser for Lojban."
HOMEPAGE="https://github.com/lojban/jbofihe"
SRC_URI="https://github.com/lojban/jbofihe/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
DEPEND="virtual/libc dev-lang/perl sys-devel/bison sys-devel/flex"
RDEPEND="${DEPEND}"
S="${WORKDIR}/${P}"

src_unpack() {
    unpack ${A}
}

src_compile() {
    econf
    emake
}

src_install() {
    default
}
