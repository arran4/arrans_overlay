# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/gui-apps-tuigreet-bin-update.yaml
EAPI=8
DESCRIPTION="Graphical console greeter for greetd"
HOMEPAGE="https://github.com/apognu/tuigreet"
SRC_URI="
  amd64? (  https://github.com/apognu/tuigreet/releases/download/v${PV}/tuigreet-${PV}-x86_64 -> ${P}-tuigreet-${PV}-x86_64  )  
"
LICENSE="GNU General Public License v3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    mkdir -p "${S}"
    cp "${DISTDIR}/${P}-tuigreet-${PV}-x86_64" "${S}/tuigreet" || die "Failed to copy executable"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "${S}/tuigreet" "tuigreet" || die "Failed to install Binary"
  fi
}
