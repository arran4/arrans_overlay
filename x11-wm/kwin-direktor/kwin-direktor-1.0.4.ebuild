EAPI=8

DESCRIPTION="An ultra-modern, zero-bloat, Wayland-First Tiling Window Manager for KDE Plasma 6"
HOMEPAGE="https://github.com/Alex-Bini/kwin-direktor"
SRC_URI="https://github.com/Alex-Bini/kwin-direktor/archive/refs/tags/v1.0.4.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	kde-plasma/kwin
	kde-frameworks/kpackage
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P/_/-}"

src_compile() {
	./package.sh || die "Package building failed"
}

src_install() {
	insinto /usr/share/kwin/scripts/direktor
	doins -r build_package/*

	exeinto /opt/bin
	doexe bin/direktor-osd
}
