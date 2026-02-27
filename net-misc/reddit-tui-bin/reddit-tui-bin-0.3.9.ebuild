# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-misc-reddit-tui-bin-update.yaml
EAPI=8
DESCRIPTION="A lightweight terminal application for browsing Reddit from your command line."
HOMEPAGE="https://github.com/tonymajestro/reddit-tui"
SRC_URI="
	amd64? (  https://github.com/tonymajestro/reddit-tui/releases/download/v${PV}/reddit-tui_Linux_x86_64.tar.gz -> ${P}-reddit-tui_Linux_x86_64.tar.gz  )
	arm64? (  https://github.com/tonymajestro/reddit-tui/releases/download/v${PV}/reddit-tui_Linux_arm64.tar.gz -> ${P}-reddit-tui_Linux_arm64.tar.gz  )
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" doc"
REQUIRED_USE=""
RDEPEND=""
S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-reddit-tui_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-reddit-tui_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "reddittui" "reddittui" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "reddittui" "reddittui" || die "Failed to install Binary"
  fi
  if use doc; then
    if use amd64; then
      newdoc "LICENSE.txt" "LICENSE.txt" || die "Failed to install document LICENSE.txt"
      newdoc "README.md" "README.md" || die "Failed to install document README.md"
    fi
  fi
}
