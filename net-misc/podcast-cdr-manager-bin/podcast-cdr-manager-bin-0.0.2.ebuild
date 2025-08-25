# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-misc-podcast-cdr-manager-bin-update.yaml
EAPI=8
DESCRIPTION="CLI tool to help manage podcast subscriptions for burning to CDROMs / CDR / CDRW"
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/podcast-cdr-manager/releases/download/v0.0.2/podcastcdrmanager_Linux_x86_64.tar.gz -> ${P}-podcastcdrmanager_Linux_x86_64.tar.gz  )  
  arm? (  https://github.com/arran4/podcast-cdr-manager/releases/download/v0.0.2/podcastcdrmanager_Linux_armv6.tar.gz -> ${P}-podcastcdrmanager_Linux_armv6.tar.gz  )  
  arm64? (  https://github.com/arran4/podcast-cdr-manager/releases/download/v0.0.2/podcastcdrmanager_Linux_arm64.tar.gz -> ${P}-podcastcdrmanager_Linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-podcastcdrmanager_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-podcastcdrmanager_Linux_armv6.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-podcastcdrmanager_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "podcastcdrmanager" "podcastcdrmanager" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "podcastcdrmanager" "podcastcdrmanager" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "podcastcdrmanager" "podcastcdrmanager" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
  fi
}

