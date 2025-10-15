# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-text-md2png-bin-update.yaml
EAPI=8
DESCRIPTION="Render Markdown directly to PNG or JPEG images with a single static Go binary."
HOMEPAGE="https://github.com/arran4/md2png"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND="sys-libs/glibc "
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/md2png/releases/download/v0.5.11/md2png_${PV}_Linux_x86_64.tar.gz -> ${P}-md2png_${PV}_Linux_x86_64.tar.gz  )  
  arm? (  https://github.com/arran4/md2png/releases/download/v0.5.11/md2png_${PV}_Linux_armv7.tar.gz -> ${P}-md2png_${PV}_Linux_armv7.tar.gz  )  
  arm64? (  https://github.com/arran4/md2png/releases/download/v0.5.11/md2png_${PV}_Linux_arm64.tar.gz -> ${P}-md2png_${PV}_Linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-md2png_${PV}_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-md2png_${PV}_Linux_armv7.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-md2png_${PV}_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "md2png" "md2png" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "md2png" "md2png" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "md2png" "md2png" || die "Failed to install Binary"
  fi
}

