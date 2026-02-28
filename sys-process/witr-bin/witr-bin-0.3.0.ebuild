# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/sys-process-witr-bin-update.yaml
EAPI=8
DESCRIPTION="A tool that answers 'Why is this running?'"
HOMEPAGE="https://github.com/pranshuparmar/witr"
SRC_URI="
	amd64? (  https://github.com/pranshuparmar/witr/releases/download/v${PV}/witr-linux-amd64 -> ${P}-witr-linux-amd64  )
	arm64? (  https://github.com/pranshuparmar/witr/releases/download/v${PV}/witr-linux-arm64 -> ${P}-witr-linux-arm64  )
"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
REQUIRED_USE=""
RDEPEND=""
S="${WORKDIR}"

src_unpack() { :; }

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "${DISTDIR}/${P}-witr-linux-amd64" "witr" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "${DISTDIR}/${P}-witr-linux-arm64" "witr" || die "Failed to install Binary"
  fi
}
