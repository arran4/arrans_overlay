EAPI=8
DESCRIPTION="Antigravity"
HOMEPAGE=""
LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""
SRC_URI="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.11.13-5784474821722112/linux-x64/Antigravity.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}"

src_unpack() {
    unpack "${DISTDIR}/${P}.tar.gz"
}

src_install() {
    exeinto /opt/bin
    newexe "Antigravity" "antigravity"
}
