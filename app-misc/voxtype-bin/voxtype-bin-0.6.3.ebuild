# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-voxtype-bin-update.yaml
EAPI=8
DESCRIPTION="Push-to-talk voice-to-text for Linux. Optimized for Wayland, works on X11 too."
HOMEPAGE="https://voxtype.io/"
SRC_URI="
  amd64? (  https://github.com/peteonrails/voxtype/releases/download/v${PV}/voxtype-${PV}-linux-x86_64-avx2 -> ${P}-voxtype-${PV}-linux-x86_64-avx2  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-voxtype-${PV}-linux-x86_64-avx2" "${S}/voxtype" || die
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "\${S}/voxtype" voxtype || die
  fi
}
