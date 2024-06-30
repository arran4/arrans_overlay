# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-im-slackdump-bin-update.yaml
EAPI=8
DESCRIPTION="Save or export your private and public Slack messages, threads, files, and users locally without admin privileges."
HOMEPAGE="https://github.com/rusq/slackdump"
IUSE="man"
SRC_URI="
  amd64? ( https://github.com/rusq/slackdump/releases/download/v${PV}/slackdump_Linux_x86_64.tar.gz -> ${P}.amd64.tar.gz )
  arm64? ( https://github.com/rusq/slackdump/releases/download/v${PV}/slackdump_Linux_arm64.tar.gz -> ${P}.arm64.tar.gz )
  x86? ( https://github.com/rusq/slackdump/releases/download/v${PV}/slackdump_Linux_i386.tar.gz -> ${P}.x86.tar.gz )
" 
LICENSE="GPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}"
RESTRICT="strip"

src_install() {
    exeinto /opt/bin
    doexe slackdump
    dodoc LICENSE README.rst
    if use man; then
      doman slackdump.1
    fi
}

