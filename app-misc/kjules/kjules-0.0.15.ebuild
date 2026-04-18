# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-kjules-update.yaml
EAPI=8

KFMIN=6.0
inherit ecm

DESCRIPTION="kjules KDE application"
HOMEPAGE="https://github.com/arran4/kjules"
SRC_URI="https://github.com/arran4/kjules/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
    dev-qt/qtbase:6[gui,widgets]
    dev-qt/qtdeclarative:6
    kde-frameworks/kcoreaddons:6
    kde-frameworks/ki18n:6
    kde-frameworks/kxmlgui:6
"
RDEPEND="${DEPEND}"
