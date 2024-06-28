# Generated via: https://github.com/arran4/arrans-private-overlay/blob/main/.github/workflows/kde-misc-arrans-kde-keyboard-shortcuts-with-meta-update.yaml
EAPI=8
DESCRIPTION="My keyboard bindings fast select."
HOMEPAGE="https://arran4.github.io/"
IUSE=""
SRC_URI="  https://github.com/arran4/kde-keyboard-shortcuts/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz "
LICENSE="unlicensed"
SLOT="0"
KEYWORDS="~alpha amd64 hppa ~ia64 ~mips ppc ppc64 ~riscv sparc x86"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${DISTDIR}"/kde-keyboard-shortcuts-${PV}/

src_unpack() {
    unpack ${A}
}

src_install() {
    insinto /usr/share/kcmkeys
    doins arrans-kde-keyboard-shortcuts-with-meta.kksrc
}

