# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-vcs-git-credential-oauth-bin-update.yaml
EAPI=8
DESCRIPTION="A Git credential helper that securely authenticates to GitHub, GitLab and BitBucket using OAuth."
HOMEPAGE="https://github.com/hickford/git-credential-oauth"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND="sys-devel/gcc sys-libs/glibc "
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/hickford/git-credential-oauth/releases/download/v0.16.0/git-credential-oauth_${PV}_linux_amd64.tar.gz -> ${P}-git-credential-oauth_${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/hickford/git-credential-oauth/releases/download/v0.16.0/git-credential-oauth_${PV}_linux_arm64.tar.gz -> ${P}-git-credential-oauth_${PV}_linux_arm64.tar.gz  )  
  x86? (  https://github.com/hickford/git-credential-oauth/releases/download/v0.16.0/git-credential-oauth_${PV}_linux_386.tar.gz -> ${P}-git-credential-oauth_${PV}_linux_386.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-git-credential-oauth_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-git-credential-oauth_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
  if use x86; then
    unpack "${DISTDIR}/${P}-git-credential-oauth_${PV}_linux_386.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "git-credential-oauth" "git-credential-oauth" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "git-credential-oauth" "git-credential-oauth" || die "Failed to install Binary"
  fi
  if use x86; then
    newexe "git-credential-oauth" "git-credential-oauth" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "LICENSE.txt" "LICENSE.txt" || die "Failed to install document LICENSE.txt"
    newdoc "README.md" "README.md" || die "Failed to install document README.md"
  fi
}

