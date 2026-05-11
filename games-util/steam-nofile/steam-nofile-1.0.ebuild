EAPI=8

DESCRIPTION="Install 26-steam-nofile.conf for Steam file descriptor limits"
HOMEPAGE="https://github.com/arran4/arrans-overlay"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}"

src_install() {
	insinto /etc/security/limits.d
	doins "${FILESDIR}/26-steam-nofile.conf"
}
