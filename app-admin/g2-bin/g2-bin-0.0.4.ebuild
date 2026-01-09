# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-admin-g2-bin-update.yaml
EAPI=8
DESCRIPTION="g2 Gentoo Tools"
HOMEPAGE="https://wiki.gentoo.org/wiki/User:Arran4"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/g2/releases/download/v0.0.4/g2_${PV}_linux_amd64.tar.gz -> ${P}-g2_${PV}_linux_amd64.tar.gz  )  
  arm? (  https://github.com/arran4/g2/releases/download/v0.0.4/g2_${PV}_linux_armv6.tar.gz -> ${P}-g2_${PV}_linux_armv6.tar.gz  )  
  arm64? (  https://github.com/arran4/g2/releases/download/v0.0.4/g2_${PV}_linux_arm64.tar.gz -> ${P}-g2_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-g2_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-g2_${PV}_linux_armv6.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-g2_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "g2" "g2" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "g2" "g2" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "g2" "g2" || die "Failed to install Binary"
  fi
}

