# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-ollama-bin-update.yaml
EAPI=8
DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other large language models."
HOMEPAGE="https://ollama.com"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+systemd -rocm"
BDEPEND="app-arch/zstd"
DEPEND="acct-user/ollama acct-group/ollama"
RDEPEND="acct-user/ollama acct-group/ollama"
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

MY_PV="${PV/_/-}"
SRC_URI="  
  amd64? ( https://github.com/ollama/ollama/releases/download/v${MY_PV}/ollama-linux-amd64.tar.zst  -> $P.amd64.tar.zst  )
  arm64? ( https://github.com/ollama/ollama/releases/download/v${MY_PV}/ollama-linux-arm64.tar.zst  -> $P.arm64.tar.zst  )
  rocm? ( https://github.com/ollama/ollama/releases/download/v${MY_PV}/ollama-linux-amd64-rocm.tar.zst -> $P.rocm.tar.zst )
" 

src_unpack() {
  if use rocm; then
    tar --zstd -xf "${DISTDIR}/${P}.rocm.tar.zst" -C "${WORKDIR}" || die "Failed to unpack rocm"
  fi
  if use amd64; then
    tar --zstd -xf "${DISTDIR}/${P}.amd64.tar.zst" -C "${WORKDIR}" || die "Failed to unpack amd64"
  elif use arm64; then
    tar --zstd -xf "${DISTDIR}/${P}.arm64.tar.zst" -C "${WORKDIR}" || die "Failed to unpack arm64"
  fi
}

src_install() {
  exeinto /opt/Ollama/bin
  doexe "${WORKDIR}/bin/ollama" || die "Failed to install binary"
  insinto /opt/Ollama/lib/
  doins -r "${WORKDIR}/lib/ollama/" || die "Failed to install libraries"
  dosym /opt/Ollama/bin/ollama /opt/bin/ollama
}

src_prepare() {
  eapply_user
}

pkg_postinst() {
  einfo "Quick guide:"
  einfo "ollama serve"
  einfo "ollama run llama3:70b"
  einfo "See available models at https://ollama.com/library"
  if use systemd; then
    einfo "Creating systemd service file..."
    {
      echo "[Unit]"
      echo "Description=Ollama Service"
      echo "After=network-online.target"
      echo ""
      echo "[Service]"
      echo "ExecStart=/opt/Ollama/bin/ollama serve"
      echo "User=ollama"
      echo "Group=ollama"
      echo "Restart=always"
      echo "RestartSec=3"
      echo ""
      echo "[Install]"
      echo "WantedBy=default.target"
    } > /usr/lib/systemd/system/ollama.service
    einfo "Service file created at /etc/systemd/system/ollama.service"
    einfo "Making service user-startable..."
    mkdir -p /etc/systemd/user
    ln -s /usr/lib/systemd/system/ollama.service /etc/systemd/user/ollama.service
    ln -s /usr/lib/systemd/system/ollama.service /etc/systemd/system/ollama.service
  fi
}

