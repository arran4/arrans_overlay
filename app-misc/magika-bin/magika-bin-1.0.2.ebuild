# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-magika-bin-update.yaml
EAPI=8
DESCRIPTION="Fast and accurate AI powered file content types detection"
HOMEPAGE="https://github.com/google/magika"
SRC_URI="
	amd64? (  https://github.com/google/magika/releases/download/cli/v${PV}/magika-x86_64-unknown-linux-gnu.tar.xz -> ${P}-magika-x86_64-unknown-linux-gnu.tar.xz  )
	arm64? (  https://github.com/google/magika/releases/download/cli/v${PV}/magika-aarch64-unknown-linux-gnu.tar.xz -> ${P}-magika-aarch64-unknown-linux-gnu.tar.xz  )
"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-magika-x86_64-unknown-linux-gnu.tar.xz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-magika-aarch64-unknown-linux-gnu.tar.xz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "magika" "magika" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "magika" "magika" || die "Failed to install Binary"
  fi
}
