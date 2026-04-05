# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-misc-abc-justin-rss-bin-update.yaml
EAPI=8
DESCRIPTION="ABC news just-in to rss converter - generated"
HOMEPAGE="https://github.com/arran4/abc-justin-rss"
SRC_URI="
	amd64? (  https://github.com/arran4/abc-justin-rss/releases/download/v${PV}/abcjustinrss_${PV}_linux_amd64.tar.gz -> ${P}-abcjustinrss_${PV}_linux_amd64.tar.gz  )  
	arm64? (  https://github.com/arran4/abc-justin-rss/releases/download/v${PV}/abcjustinrss_${PV}_linux_arm64.tar.gz -> ${P}-abcjustinrss_${PV}_linux_arm64.tar.gz  )  
	x86? (  https://github.com/arran4/abc-justin-rss/releases/download/v${PV}/abcjustinrss_${PV}_linux_386.tar.gz -> ${P}-abcjustinrss_${PV}_linux_386.tar.gz  )  
"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-abcjustinrss_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-abcjustinrss_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-abcjustinrss_${PV}_linux_386.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /usr/bin
  if use amd64; then
    newexe "abcjustinrss" "abcjustinrss" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "abcjustinrss" "abcjustinrss" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "abcjustinrss" "abcjustinrss" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
    newdoc "readme.md" "README.md" || die "Failed to install document README.md"
  fi
}
