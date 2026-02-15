# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-vcs-diffnav-bin-update.yaml
EAPI=8
DESCRIPTION="A git diff pager based on delta but with a file tree, à la GitHub."
HOMEPAGE="https://github.com/dlvhdr/diffnav"
SRC_URI="
	amd64? ( https://github.com/dlvhdr/diffnav/releases/download/v${PV}/diffnav_Linux_x86_64.tar.gz -> ${P}-diffnav_Linux_x86_64.tar.gz )
	arm64? ( https://github.com/dlvhdr/diffnav/releases/download/v${PV}/diffnav_Linux_arm64.tar.gz -> ${P}-diffnav_Linux_arm64.tar.gz )
	x86? ( https://github.com/dlvhdr/diffnav/releases/download/v${PV}/diffnav_Linux_i386.tar.gz -> ${P}-diffnav_Linux_i386.tar.gz )
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc"
REQUIRED_USE=""
RDEPEND="
	dev-vcs/git
	dev-util/git-delta
"

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-diffnav_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-diffnav_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-diffnav_Linux_i386.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "diffnav" "diffnav" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "diffnav" "diffnav" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "diffnav" "diffnav" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "LICENSE.txt" "LICENSE.txt" || die "Failed to install document LICENSE.txt"
    newdoc "README.md" "README.md" || die "Failed to install document README.md"
  fi
}
