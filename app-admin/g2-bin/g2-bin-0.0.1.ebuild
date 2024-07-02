# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-admin-g2-bin-update.yaml
EAPI=8
DESCRIPTION="Arrans Gentoo specific tools"
HOMEPAGE="https://github.com/arran4/g2/"
IUSE=""
SRC_URI="
  amd64? ( https://github.com/arran4/g2/releases/download/v${PV}/g2_${PV}_linux_amd64.tar.gz -> ${P}.amd64.tar.gz )
  arm? ( https://github.com/arran4/g2/releases/download/v${PV}/g2_${PV}_linux_armv7.tar.gz -> ${P}.arm.tar.gz )
  arm64? ( https://github.com/arran4/g2/releases/download/v${PV}/g2_${PV}_linux_arm64.tar.gz -> ${P}.arm64.tar.gz )
" 
LICENSE="Unknown"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_install() {
    exeinto /opt/bin
    doexe g2
}

