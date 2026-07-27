EAPI=8
DESCRIPTION="A cross-platform screenshot tool written in Go"
HOMEPAGE="https://github.com/watzon/goshot"
SRC_URI="
    amd64? ( https://github.com/watzon/goshot/releases/download/v${PV}/goshot_Linux_x86_64.tar.gz -> goshot-${PV}_Linux_x86_64.tar.gz )
    arm? ( https://github.com/watzon/goshot/releases/download/v${PV}/goshot_Linux_arm.tar.gz -> goshot-${PV}_Linux_arm.tar.gz )
    arm64? ( https://github.com/watzon/goshot/releases/download/v${PV}/goshot_Linux_arm64.tar.gz -> goshot-${PV}_Linux_arm64.tar.gz )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
RESTRICT="strip"

S="${WORKDIR}"

src_install() {
    dobin goshot
}
