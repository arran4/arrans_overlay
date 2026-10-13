EAPI=8

DESCRIPTION="UnixTree is a powerful and versatile console-mode filemanager for Unix-style systems"
HOMEPAGE="https://github.com/dokakod/unixtree"
SRC_URI="https://github.com/dokakod/unixtree/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	x11-libs/libX11
	x11-libs/libXt
"
RDEPEND="${DEPEND}"

src_configure() {
	sh build -r linux || die "build setup failed"
}

src_compile() {
	emake
}

src_install() {
	INS_DIR="${ED}/usr" emake install
}
