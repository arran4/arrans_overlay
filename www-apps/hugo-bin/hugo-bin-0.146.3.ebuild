# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/www-apps-hugo-bin-update.yaml
EAPI=8
DESCRIPTION="The world’s fastest framework for building websites."
HOMEPAGE="https://gohugo.io"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=" extended"
REQUIRED_USE="extended? ( || ( amd64 arm64  ) ) "
DEPEND=""
RDEPEND="extended? ( sys-devel/gcc sys-libs/glibc  ) "
S="${WORKDIR}"


SRC_URI="
  amd64? ( !extended? (  https://github.com/gohugoio/hugo/releases/download/v0.146.3/hugo_${PV}_linux-amd64.tar.gz -> ${P}-hugo_${PV}_linux-amd64.tar.gz  )  )  
  amd64? ( extended? (  https://github.com/gohugoio/hugo/releases/download/v0.146.3/hugo_extended_${PV}_Linux-64bit.tar.gz -> ${P}-hugo_extended_${PV}_Linux-64bit.tar.gz  )  )  
  arm? (  https://github.com/gohugoio/hugo/releases/download/v0.146.3/hugo_${PV}_linux-arm.tar.gz -> ${P}-hugo_${PV}_linux-arm.tar.gz  )  
  arm64? ( !extended? (  https://github.com/gohugoio/hugo/releases/download/v0.146.3/hugo_${PV}_linux-arm64.tar.gz -> ${P}-hugo_${PV}_linux-arm64.tar.gz  )  )  
  arm64? ( extended? (  https://github.com/gohugoio/hugo/releases/download/v0.146.3/hugo_extended_${PV}_linux-arm64.tar.gz -> ${P}-hugo_extended_${PV}_linux-arm64.tar.gz  )  )  
"

src_unpack() {
  if use amd64 && ! use extended ; then
    unpack "${DISTDIR}/${P}-hugo_${PV}_linux-amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use amd64 && use extended; then
    unpack "${DISTDIR}/${P}-hugo_extended_${PV}_Linux-64bit.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-hugo_${PV}_linux-arm.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64 && ! use extended ; then
    unpack "${DISTDIR}/${P}-hugo_${PV}_linux-arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64 && use extended; then
    unpack "${DISTDIR}/${P}-hugo_extended_${PV}_linux-arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64 && ! use extended ; then
    newexe "hugo" "hugo" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "hugo" "hugo" || die "Failed to install Binary"
  fi
  if use arm64 && ! use extended ; then
    newexe "hugo" "hugo" || die "Failed to install Binary"
  fi
  if use amd64 && use extended; then
    newexe "hugo" "hugo" || die "Failed to install Binary"
  fi
  if use arm64 && use extended; then
    newexe "hugo" "hugo" || die "Failed to install Binary"
  fi
}

