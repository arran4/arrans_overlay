EAPI=8

DESCRIPTION="Create Electron app packages."
HOMEPAGE="https://github.com/electron/asar"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

DEPEND="net-libs/nodejs"
RDEPEND="${DEPEND}"
BDEPEND="net-libs/nodejs"

RESTRICT="network-sandbox"

S="${WORKDIR}"

src_install() {
	npm install -g --prefix="${ED}/usr" @electron/asar@${PV} || die
}
