EAPI=8

inherit ecm

DESCRIPTION="kjules KDE application"
HOMEPAGE="https://github.com/arran4/kjules"
SRC_URI="https://github.com/arran4/kjules/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
    dev-qt/qtbase:6
    dev-qt/qtdeclarative:6
    kde-frameworks/kcoreaddons:6
    kde-frameworks/ki18n:6
    kde-frameworks/kxmlgui:6
"
RDEPEND="${DEPEND}"

src_configure() {
    local mycmakeargs=(
        -DBUILD_TESTING=OFF
    )
    ecm_src_configure
}
