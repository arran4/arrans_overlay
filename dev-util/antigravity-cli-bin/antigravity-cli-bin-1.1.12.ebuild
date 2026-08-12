# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-antigravity-cli-bin-update.yaml
EAPI=8
DESCRIPTION="Antigravity CLI"
HOMEPAGE="https://github.com/google-antigravity/antigravity-cli"
SRC_URI="
	amd64? (  https://github.com/google-antigravity/antigravity-cli/releases/download/${PV}/agy_cli_linux_x64.tar.gz -> ${P}-agy_cli_linux_x64.tar.gz  )
	arm64? (  https://github.com/google-antigravity/antigravity-cli/releases/download/${PV}/agy_cli_linux_arm64.tar.gz -> ${P}-agy_cli_linux_arm64.tar.gz  )
"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" amd64 arm64"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-agy_cli_linux_x64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-agy_cli_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "antigravity" "antigravity" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "antigravity" "antigravity" || die "Failed to install Binary"
  fi
}
