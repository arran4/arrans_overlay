# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: b6df98d10b5e693e210c8f7df3eaac3e2390499b
#   workflow: .github/workflows/dev-vcs-git-tag-inc-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Yet another semantic version incrementor and tagger for git"
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/git-tag-inc/releases/download/v1.3.10/git-tag-inc_1.3.10_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-git-tag-inc_${PV}_linux_amd64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/arran4/git-tag-inc/releases/download/v1.3.10/git-tag-inc_1.3.10_linux_armv7.tar.gz "
SRC_URI+=" -> ${P}-git-tag-inc_${PV}_linux_armv7.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/git-tag-inc/releases/download/v1.3.10/git-tag-inc_1.3.10_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-git-tag-inc_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="unknown"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-git-tag-inc_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-git-tag-inc_${PV}_linux_armv7.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-git-tag-inc_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"git-tag-inc" \
			"git-tag-inc" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"git-tag-inc" \
			"git-tag-inc" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"git-tag-inc" \
			"git-tag-inc" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		if use amd64; then
			dodoc "readme.md" || die "Failed to install document readme.md"
		fi
		if use arm; then
			dodoc "readme.md" || die "Failed to install document readme.md"
			dodoc "readme.md" || die "Failed to install document readme.md"
		fi
		if use arm64; then
			dodoc "readme.md" || die "Failed to install document readme.md"
		fi
	fi
}
