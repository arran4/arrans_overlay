EAPI=8

inherit ecm

DESCRIPTION="Linux/KDE port of whatcable, tells what each USB connected cable can do"
HOMEPAGE="https://github.com/Zetaphor/whatcable-linux"
SRC_URI="https://github.com/Zetaphor/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kirigami:6
	kde-frameworks/kpackage:6
	kde-plasma/libplasma:6
	virtual/libudev:=
"
RDEPEND="${DEPEND}
	kde-plasma/plasma-workspace:6
"
BDEPEND="
	virtual/pkgconfig
"
