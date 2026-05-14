EAPI=8

DESCRIPTION="Sets high file descriptor limits for Steam"
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
