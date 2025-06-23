# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-admin-chezmoi-bin-update.yaml
EAPI=8
DESCRIPTION="Manage your dotfiles across multiple diverse machines, securely."
HOMEPAGE="https://www.chezmoi.io/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~s390 ~x86"
IUSE=" android glibc le loong64"
REQUIRED_USE="android? ( || ( arm64  ) ) glibc? ( || ( amd64  ) ) le? ( || ( ppc64  ) ) loong64? ( || ( amd64  ) ) "
DEPEND=""
RDEPEND="sys-libs/glibc glibc? ( sys-libs/glibc  ) "
S="${WORKDIR}"


SRC_URI="
  amd64? ( glibc? ( !loong64? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux-glibc_amd64.tar.gz -> ${P}-chezmoi_${PV}_linux-glibc_amd64.tar.gz  )  )  )  
  amd64? ( !glibc? ( !loong64? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux-musl_amd64.tar.gz -> ${P}-chezmoi_${PV}_linux-musl_amd64.tar.gz  )  )  )  
  amd64? ( loong64? ( !glibc? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux_loong64.tar.gz -> ${P}-chezmoi_${PV}_linux_loong64.tar.gz  )  )  )  
  arm? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux_arm.tar.gz -> ${P}-chezmoi_${PV}_linux_arm.tar.gz  )  
  arm64? ( android? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_android_arm64.tar.gz -> ${P}-chezmoi_${PV}_android_arm64.tar.gz  )  )  
  arm64? ( !android? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux_arm64.tar.gz -> ${P}-chezmoi_${PV}_linux_arm64.tar.gz  )  )  
  ppc64? ( !le? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux_ppc64.tar.gz -> ${P}-chezmoi_${PV}_linux_ppc64.tar.gz  )  )  
  ppc64? ( le? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux_ppc64le.tar.gz -> ${P}-chezmoi_${PV}_linux_ppc64le.tar.gz  )  )  
  riscv? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux_riscv64.tar.gz -> ${P}-chezmoi_${PV}_linux_riscv64.tar.gz  )  
  s390? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux_s390x.tar.gz -> ${P}-chezmoi_${PV}_linux_s390x.tar.gz  )  
  x86? (  https://github.com/twpayne/chezmoi/releases/download/v2.62.7/chezmoi_${PV}_linux_i386.tar.gz -> ${P}-chezmoi_${PV}_linux_i386.tar.gz  )  
"

src_unpack() {
  if use amd64 && use glibc && ! use loong64 ; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux-glibc_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use amd64 && ! use glibc  && ! use loong64 ; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux-musl_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use amd64 && use loong64 && ! use glibc ; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_loong64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_arm.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64 && use android; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_android_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64 && ! use android ; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use ppc64 && ! use le ; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_ppc64.tar.gz" || die "Can't unpack archive file"
  fi
  if use ppc64 && use le; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_ppc64le.tar.gz" || die "Can't unpack archive file"
  fi
  if use riscv; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_riscv64.tar.gz" || die "Can't unpack archive file"
  fi
  if use s390; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_s390x.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_i386.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use arm64 && use android; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use amd64 && ! use glibc  && ! use loong64 ; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use arm; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use arm64 && ! use android ; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use ppc64 && ! use le ; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use riscv; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use s390; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use amd64 && use glibc && ! use loong64 ; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use ppc64 && use le; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
  if use amd64 && use loong64 && ! use glibc ; then
    newexe "chezmoi" "chezmoi" || die "Failed to install Binary"
  fi
}

