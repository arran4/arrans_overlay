# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/www-apps-hugo-bin-update.yaml
EAPI=8
DESCRIPTION="The world’s fastest framework for building websites."
HOMEPAGE="https://gohugo.io/"
IUSE="+extended"
SRC_URI="  
  amd64? ( extended? ( https://github.com/gohugoio/hugo/releases/download/v${PV}/hugo_extended_${PV}_Linux-64bit.tar.gz -> ${PN}_extended-${PV}.amd64.tar.gz ) !extended? ( https://github.com/gohugoio/hugo/releases/download/v${PV}/hugo_${PV}_Linux-64bit.tar.gz -> ${P}.amd64.tar.gz ) )
  arm? ( extended? ( https://github.com/gohugoio/hugo/releases/download/v${PV}/hugo_extended_${PV}_linux-arm.tar.gz -> ${PN}_extended-${PV}.arm.tar.gz ) !extended? ( https://github.com/gohugoio/hugo/releases/download/v${PV}/hugo_${PV}_linux-arm.tar.gz -> ${P}.arm.tar.gz ) )
  arm64? ( extended? ( https://github.com/gohugoio/hugo/releases/download/v${PV}/hugo_extended_${PV}_linux-arm64.tar.gz -> ${PN}_extended-${PV}.arm64.tar.gz ) !extended? ( https://github.com/gohugoio/hugo/releases/download/v${PV}/hugo_${PV}_linux-arm64.tar.gz -> ${P}.arm64.tar.gz ) )
" 
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
RDEPEND="
	extended? (
		dev-libs/libsass:=
		>=media-libs/libwebp-1.3.2:=
	)
"
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_install() {
    exeinto /opt/bin
    doexe hugo
}

