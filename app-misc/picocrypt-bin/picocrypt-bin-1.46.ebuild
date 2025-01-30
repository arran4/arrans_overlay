# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-picocrypt-bin-update.yaml
EAPI=8
DESCRIPTION="A very small, very simple, yet very secure encryption tool."
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND="media-libs/libglvnd sys-devel/gcc sys-libs/glibc x11-libs/gtk+ x11-libs/libX11 "
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/Picocrypt/Picocrypt/releases/download/1.46/Picocrypt -> ${P}-Picocrypt  )  
"

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "${DISTDIR}/${P}-Picocrypt" "Picocrypt" || die "Failed to install Binary"
  fi
}

