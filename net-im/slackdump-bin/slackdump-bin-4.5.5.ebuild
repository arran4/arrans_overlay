# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 1b69dd1b21f52e1cc34ebb763f82a3a6a8bef4c9
#   workflow: .github/workflows/net-im-slackdump-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Save or export your private and public Slack messages, threads, "
DESCRIPTION+="files, and users locally without admin privileges."
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/rusq/slackdump/releases/download/v4.5.5/slackdump_Linux_x86_64.tar.gz "
SRC_URI+=" -> ${P}-slackdump_Linux_x86_64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/rusq/slackdump/releases/download/v4.5.5/slackdump_Linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-slackdump_Linux_arm64.tar.gz  )   x86? (   "
SRC_URI+="https://github.com/rusq/slackdump/releases/download/v4.5.5/slackdump_Linux_i386.tar.gz "
SRC_URI+=" -> ${P}-slackdump_Linux_i386.tar.gz  )  "
LICENSE=""
LICENSE+="GNU General Public License v3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-slackdump_Linux_x86_64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-slackdump_Linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-slackdump_Linux_i386.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"slackdump" \
			"slackdump" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"slackdump" \
			"slackdump" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"slackdump" \
			"slackdump" \
			|| die "Failed to install Binary"
	fi
}
