# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-vcs-git-tag-inc-bin-update.yaml
EAPI=8
DESCRIPTION="Yet another semantic version incrementor and tagger for git"
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
  amd64? (  https://github.com/arran4/git-tag-inc/releases/download/v1.1.7/git-tag-inc_${PV}_linux_amd64.tar.gz -> ${P}-git-tag-inc_${PV}_linux_amd64.tar.gz  )  
  arm? (  https://github.com/arran4/git-tag-inc/releases/download/v1.1.7/git-tag-inc_${PV}_linux_armv7.tar.gz -> ${P}-git-tag-inc_${PV}_linux_armv7.tar.gz  )  
  arm64? (  https://github.com/arran4/git-tag-inc/releases/download/v1.1.7/git-tag-inc_${PV}_linux_arm64.tar.gz -> ${P}-git-tag-inc_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-git-tag-inc_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-git-tag-inc_${PV}_linux_armv7.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-git-tag-inc_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "git-tag-inc" "git-tag-inc" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "git-tag-inc" "git-tag-inc" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "git-tag-inc" "git-tag-inc" || die "Failed to install Binary"
  fi
  if use doc; then
    if use amd64; then
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
    fi
    if use arm; then
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
    fi
    if use arm64; then
      newdoc "readme.md" "readme.md" || die "Failed to install document readme.md"
    fi
  fi
}

