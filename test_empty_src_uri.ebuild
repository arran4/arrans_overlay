EAPI=8
DESCRIPTION="Test ebuild"
HOMEPAGE="https://example.com"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="network-sandbox"
PROPERTIES="live"
S="${WORKDIR}"

src_unpack() {
    echo "test"
}
