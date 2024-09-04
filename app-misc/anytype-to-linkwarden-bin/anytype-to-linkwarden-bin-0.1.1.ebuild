# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-anytype-to-linkwarden-bin-update.yaml
EAPI=8
DESCRIPTION="TODO"
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" anytype-to-linkwarden doc"
REQUIRED_USE="anytype-to-linkwarden? ( || ( amd64  ) ) "
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? ( anytype-to-linkwarden? ( !anytype-to-linkwarden? (  https://github.com/arran4/anytype-to-linkwarden/releases/download/v0.1.1/anytype-to-linkwarden_${PV}_linux_amd64.tar.gz -> ${P}-anytype-to-linkwarden_${PV}_linux_amd64.tar.gz  )  )  )  
  arm64? (  https://github.com/arran4/anytype-to-linkwarden/releases/download/v0.1.1/anytype-to-linkwarden_${PV}_linux_arm64.tar.gz -> ${P}-anytype-to-linkwarden_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64 && use anytype-to-linkwarden && ! use anytype-to-linkwarden ; then
    unpack "${DISTDIR}/${P}-anytype-to-linkwarden_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-anytype-to-linkwarden_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64 && use anytype-to-linkwarden && ! use anytype-to-linkwarden ; then
    newexe "anytype-to-linkwarden" "anytype-to-linkwarden" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "anytype-to-linkwarden" "anytype-to-linkwarden" || die "Failed to install Binary"
  fi
  if use doc; then
    if use amd64; then
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
    fi
    if use arm64; then
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
    fi
  fi
}

