# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-anytype-to-linkwarden-bin-update.yaml
EAPI=8
DESCRIPTION="TODO"
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" migrate-json-export doc"
REQUIRED_USE="
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? ( migrate-json-export? (  https://github.com/arran4/anytype-to-linkwarden/releases/download/v0.1.0/migrate-json-export_${PV}_linux_amd64.tar.gz -> ${P}-migrate-json-export_${PV}_linux_amd64.tar.gz  )  )  
  arm64? (  https://github.com/arran4/anytype-to-linkwarden/releases/download/v0.1.0/migrate-json-export_${PV}_linux_arm64.tar.gz -> ${P}-migrate-json-export_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64 && use migrate-json-export; then
    unpack "${DISTDIR}/${P}-migrate-json-export_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-migrate-json-export_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64 && use migrate-json-export; then
    newexe "migrate-json-export" "migrate-json-export" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "migrate-json-export" "migrate-json-export" || die "Failed to install Binary"
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

