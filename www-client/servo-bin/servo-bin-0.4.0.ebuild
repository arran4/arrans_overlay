# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/www-client-servo-bin-update.yaml
EAPI=8
DESCRIPTION="Servo, the embeddable, independent, memory-safe, modular, parallel web rendering engine"
HOMEPAGE="https://servo.org/"
SRC_URI="
	amd64? (  https://github.com/servo/servo/releases/download/0.4.0/servo-x86_64-linux-gnu.tar.gz -> ${P}-servo-x86_64-linux-gnu.tar.gz  )
"
LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=" amd64"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-servo-x86_64-linux-gnu.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "servo/servoshell" "servo" || die "Failed to install Binary"
  fi
}
