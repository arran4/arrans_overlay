# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-openai-desktop-bin-update.yaml
EAPI=8
DESCRIPTION="Lightweight coding agent that runs in your terminal"
HOMEPAGE="https://openai.com/codex/"
SRC_URI="
	amd64? (  https://github.com/openai/codex/releases/download/rust-v0.147.0/codex-x86_64-unknown-linux-musl.tar.gz -> ${P}-codex-x86_64-unknown-linux-musl.tar.gz  )  
	arm64? (  https://github.com/openai/codex/releases/download/rust-v0.147.0/codex-aarch64-unknown-linux-musl.tar.gz -> ${P}-codex-aarch64-unknown-linux-musl.tar.gz  )  
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-codex-x86_64-unknown-linux-musl.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-codex-aarch64-unknown-linux-musl.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "codex" "openai-desktop" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "codex" "openai-desktop" || die "Failed to install Binary"
  fi
}
