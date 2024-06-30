# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-go-goreleaser-bin-update.yaml
EAPI=8
DESCRIPTION=" Deliver Go binaries as fast and easily as possible."
HOMEPAGE="https://goreleaser.com/"
IUSE="man"
SRC_URI="
  amd64? ( https://github.com/goreleaser/goreleaser/releases/download/v${PV}/goreleaser_Linux_x86_64.tar.gz -> ${P}.amd64.tar.gz )
  arm? ( https://github.com/goreleaser/goreleaser/releases/download/v${PV}/goreleaser_Linux_armv7.tar.gz -> ${P}.arm.tar.gz )
  arm64? ( https://github.com/goreleaser/goreleaser/releases/download/v${PV}/goreleaser_Linux_arm64.tar.gz -> ${P}.arm64.tar.gz )
  x86? ( https://github.com/goreleaser/goreleaser/releases/download/v${PV}/goreleaser_Linux_i386.tar.gz -> ${P}.x86.tar.gz )
" 
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_install() {
    exeinto /opt/bin
    doexe goreleaser
    dodoc LICENSE.md README.md
    insinto /usr/share/bash-completion/completions
    doins completions/goreleaser.bash
    insinto /usr/share/fish/vendor_completions.d
    doins completions/goreleaser.fish
    insinto /usr/share/zsh/site-functions
    doins completions/goreleaser.zsh
    if use man; then
      doman manpages/goreleaser.1.gz
    fi
}

