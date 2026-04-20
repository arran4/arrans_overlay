EAPI=8
DESCRIPTION="Test ebuild"
HOMEPAGE="https://example.com"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
PROPERTIES="live"
S="${WORKDIR}"

src_unpack() {
    wget -qO "ente_auth.AppImage" "https://example.com" || die "Can't download file"
}
