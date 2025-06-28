# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-local-ai-bin-update.yaml
EAPI=8
DESCRIPTION=":robot: The free, Open Source alternative to OpenAI, Claude and others. Self-hosted and local-first. Drop-in replacement for OpenAI,  running on consumer-grade hardware. No GPU required. Runs gguf, transformers, diffusers and many more models architectures. Features: Generate Text, Audio, Video, Images, Voice Cloning, Distributed inference"
HOMEPAGE="https://localai.io"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
REQUIRED_USE=""
DEPEND=""
RDEPEND="sys-libs/glibc "
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/mudler/LocalAI/releases/download/v3.1.1/local-ai-Linux-x86_64 -> ${P}-local-ai-Linux-x86_64  )  
  arm64? (  https://github.com/mudler/LocalAI/releases/download/v3.1.1/local-ai-Linux-arm64 -> ${P}-local-ai-Linux-arm64  )  
"

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "${DISTDIR}/${P}-local-ai-Linux-x86_64" "local-ai" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "${DISTDIR}/${P}-local-ai-Linux-arm64" "local-ai" || die "Failed to install Binary"
  fi
}

