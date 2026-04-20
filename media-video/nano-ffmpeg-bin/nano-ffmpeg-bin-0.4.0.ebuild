# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/media-video-nano-ffmpeg-bin-update.yaml
EAPI=8
DESCRIPTION="nano-ffmpeg wraps the full power of ffmpeg in a beautiful, keyboard-driven terminal dashboard."
HOMEPAGE="https://github.com/dgr8akki/nano-ffmpeg"
SRC_URI="
  amd64? (  https://github.com/dgr8akki/nano-ffmpeg/releases/download/v${PV}/nano-ffmpeg_v${PV}_linux_amd64.tar.gz -> ${P}-nano-ffmpeg_v${PV}_linux_amd64.tar.gz  )
  arm64? (  https://github.com/dgr8akki/nano-ffmpeg/releases/download/v${PV}/nano-ffmpeg_v${PV}_linux_arm64.tar.gz -> ${P}-nano-ffmpeg_v${PV}_linux_arm64.tar.gz  )
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-nano-ffmpeg_v${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-nano-ffmpeg_v${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "nano-ffmpeg" "nano-ffmpeg" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "nano-ffmpeg" "nano-ffmpeg" || die "Failed to install Binary"
  fi
}
