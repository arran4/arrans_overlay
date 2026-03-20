# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/media-sound-go-playerctl-bin-update.yaml
EAPI=8
DESCRIPTION="mpris media player command-line controller for vlc, mpv, RhythmBox, web browsers, cmus, mpd, spotify and others"
HOMEPAGE="https://github.com/arran4/go-playerctl"
SRC_URI="
  amd64? (  https://github.com/arran4/go-playerctl/releases/download/v${PV}/go-playerctl_${PV}_linux_amd64.tar.gz -> ${P}-go-playerctl_${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/arran4/go-playerctl/releases/download/v${PV}/go-playerctl_${PV}_linux_arm64.tar.gz -> ${P}-go-playerctl_${PV}_linux_arm64.tar.gz  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" doc"

REQUIRED_USE=""

RDEPEND="!media-sound/go-playerctl "

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-go-playerctl_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-go-playerctl_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /usr/bin
  if use amd64; then
    newexe "goplayerctl" "go-playerctl" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "goplayerctl" "go-playerctl" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "COPYING" "COPYING" || die "Failed to install document COPYING"
    newdoc "README.md" "README.md" || die "Failed to install document README.md"
  fi
  dosym go-playerctl /usr/bin/go-playerctld
}
