# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-dasel-bin-update.yaml
EAPI=8
DESCRIPTION="Unified querying, transformation, and modification of JSON, TOML, YAML, XML, INI, HCL, KDL and CSV."
HOMEPAGE="https://github.com/TomWright/dasel"
SRC_URI="
	amd64? (  https://github.com/TomWright/dasel/releases/download/v${PV}/dasel_linux_amd64.gz -> ${P}-dasel_linux_amd64.gz  )
	arm64? (  https://github.com/TomWright/dasel/releases/download/v${PV}/dasel_linux_arm64.gz -> ${P}-dasel_linux_arm64.gz  )
	x86? (  https://github.com/TomWright/dasel/releases/download/v${PV}/dasel_linux_386.gz -> ${P}-dasel_linux_386.gz  )
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-dasel_linux_amd64.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-dasel_linux_arm64.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-dasel_linux_386.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "${P}-dasel_linux_amd64" "dasel" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "${P}-dasel_linux_arm64" "dasel" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "${P}-dasel_linux_386" "dasel" || die "Failed to install Binary"
  fi
}
