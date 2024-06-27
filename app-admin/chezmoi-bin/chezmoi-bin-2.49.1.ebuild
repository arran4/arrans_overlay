# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-admin-chezmoi-bin-update.yaml
EAPI=8
DESCRIPTION="Manage your dotfiles across multiple diverse machines, securely."
HOMEPAGE="https://www.chezmoi.io/"
IUSE="musl"
SRC_URI="
  !musl? ( amd64? ( https://github.com/twpayne/chezmoi/releases/download/v${PV}/chezmoi_${PV}_linux_amd64.tar.gz -> ${P}.amd64.tar.gz ) )
  musl? ( amd64? ( https://github.com/twpayne/chezmoi/releases/download/v${PV}/chezmoi_${PV}_linux-musl_amd64.tar.gz -> ${P}-musl.amd64.tar.gz ) )
  arm? ( https://github.com/twpayne/chezmoi/releases/download/v${PV}/chezmoi_${PV}_linux_arm.tar.gz -> ${P}.arm.tar.gz )
  arm64? ( https://github.com/twpayne/chezmoi/releases/download/v${PV}/chezmoi_${PV}_linux_arm64.tar.gz -> ${P}.arm64.tar.gz )
  x86? ( https://github.com/twpayne/chezmoi/releases/download/v${PV}/chezmoi_${PV}_linux_i386.tar.gz -> ${P}.x86.tar.gz )
" 
LICENSE="Unknown"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_install() {
    exeinto /opt/bin
    doexe chezmoi
    dodoc LICENSE README.md
    insinto /usr/share/bash-completion/completions
    doins completions/chezmoi-completion.bash
    insinto /usr/share/fish/vendor_completions.d
    doins completions/chezmoi.fish
    insinto /usr/share/zsh/site-functions
    doins completions/chezmoi.zsh
    insinto /usr/share/powershell/Modules
    doins completions/chezmoi.ps1
}

