# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-rntocase-bin-update.yaml
EAPI=8
DESCRIPTION="Some utilities to rename files, to upper, lower, title, camel, kebab, darwin case and many more"
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/arran4/rntocase/releases/download/v0.0.4/rntocase_${PV}_linux_amd64.tar.gz -> ${P}-rntocase_${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/arran4/rntocase/releases/download/v0.0.4/rntocase_${PV}_linux_arm64.tar.gz -> ${P}-rntocase_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-rntocase_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-rntocase_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "rnreverse" "rnreverse" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rnreverse" "rnreverse" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntocamel" "rntocamel" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntocamel" "rntocamel" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntodarwin" "rntodarwin" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntodarwin" "rntodarwin" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntodelimited" "rntodelimited" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntodelimited" "rntodelimited" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntokebab" "rntokebab" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntokebab" "rntokebab" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntolowerleading" "rntolowerleading" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntolowerleading" "rntolowerleading" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntosnake" "rntosnake" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntosnake" "rntosnake" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntotitle" "rntotitle" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntotitle" "rntotitle" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntoupperleading" "rntoupperleading" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntoupperleading" "rntoupperleading" || die "Failed to install Binary"
  fi
  if use amd64; then
    newexe "rntrim" "rntrim" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "rntrim" "rntrim" || die "Failed to install Binary"
  fi
  if use doc; then
    if use amd64; then
      newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
      newdoc "LICENSE" "LICENSE" || die "Failed to install document LICENSE"
    fi
  fi
}

