# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-im-slackdump-bin-update.yaml
EAPI=8
DESCRIPTION="Save or export your private and public Slack messages, threads, files, and users locally without admin privileges."
HOMEPAGE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/rusq/slackdump/releases/download/v3.1.6/slackdump_Linux_x86_64.tar.gz -> ${P}-slackdump_Linux_x86_64.tar.gz  )  
  arm64? (  https://github.com/rusq/slackdump/releases/download/v3.1.6/slackdump_Linux_arm64.tar.gz -> ${P}-slackdump_Linux_arm64.tar.gz  )  
  x86? (  https://github.com/rusq/slackdump/releases/download/v3.1.6/slackdump_Linux_i386.tar.gz -> ${P}-slackdump_Linux_i386.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-slackdump_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-slackdump_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-slackdump_Linux_i386.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "slackdump" "slackdump" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "slackdump" "slackdump" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "slackdump" "slackdump" || die "Failed to install Binary"
  fi
}

