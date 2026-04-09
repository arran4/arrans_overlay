# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-vcs-git-sync-bin-update.yaml
EAPI=8
DESCRIPTION="A simple tool to backup and sync your git repositories"
HOMEPAGE="https://github.com/AkashRajpurohit/git-sync"
SRC_URI="
  amd64? (  https://github.com/AkashRajpurohit/git-sync/releases/download/v${PV}/git-sync_${PV}_linux_amd64.tar.gz -> ${P}-git-sync_${PV}_linux_amd64.tar.gz  )  
  arm? (  https://github.com/AkashRajpurohit/git-sync/releases/download/v${PV}/git-sync_${PV}_linux_armv7.tar.gz -> ${P}-git-sync_${PV}_linux_armv7.tar.gz  )  
  arm64? (  https://github.com/AkashRajpurohit/git-sync/releases/download/v${PV}/git-sync_${PV}_linux_arm64.tar.gz -> ${P}-git-sync_${PV}_linux_arm64.tar.gz  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-git-sync_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-git-sync_${PV}_linux_armv7.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-git-sync_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /usr/bin
  if use amd64; then
    newexe "git-sync" "git-sync" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "git-sync" "git-sync" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "git-sync" "git-sync" || die "Failed to install Binary"
  fi
}
