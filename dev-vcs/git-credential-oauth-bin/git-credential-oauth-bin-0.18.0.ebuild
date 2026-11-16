# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: a4ffbab1344f706f3423c3480f84c6a459c93f7f
#   workflow: .github/workflows/dev-vcs-git-credential-oauth-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="A Git credential helper that securely authenticates to GitHub, "
DESCRIPTION+="GitLab and BitBucket using OAuth."
HOMEPAGE=""
HOMEPAGE+="https://github.com/hickford/git-credential-oauth"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/hickford/git-credential-oauth/releases/download/v0.18.0/git-credential-oauth_0.18.0_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-git-credential-oauth_${PV}_linux_amd64.tar.gz  )   arm64? ( "
SRC_URI+="  "
SRC_URI+="https://github.com/hickford/git-credential-oauth/releases/download/v0.18.0/git-credential-oauth_0.18.0_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-git-credential-oauth_${PV}_linux_arm64.tar.gz  )   x86? (   "
SRC_URI+="https://github.com/hickford/git-credential-oauth/releases/download/v0.18.0/git-credential-oauth_0.18.0_linux_386.tar.gz "
SRC_URI+=" -> ${P}-git-credential-oauth_${PV}_linux_386.tar.gz  )  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""
RDEPEND+="sys-devel/gcc "

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-git-credential-oauth_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-git-credential-oauth_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-git-credential-oauth_${PV}_linux_386.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"git-credential-oauth" \
			"git-credential-oauth" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"git-credential-oauth" \
			"git-credential-oauth" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"git-credential-oauth" \
			"git-credential-oauth" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "LICENSE.txt" || die "Failed to install document LICENSE.txt"
		dodoc "README.md" || die "Failed to install document README.md"
	fi
}
