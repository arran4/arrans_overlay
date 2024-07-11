# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/
EAPI=8
DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other large language models."
HOMEPAGE="https://ollama.com"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+systemd -rocm"
DEPEND="acct-user/ollama acct-group/ollama"
RDEPEND="acct-user/ollama acct-group/ollama"
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="  
  amd64? ( https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-amd64 -> $P.amd64 )
  arm64? ( https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-arm64 -> $P.arm64 )
  rocm? ( https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-amd64-rocm.tgz -> $P.rocm.tgz )
" 

src_unpack() {
  if use rocm; then
    tar -xzvf ${DISTDIR}/${P}.rocm.tgz -C ${WORKDIR} || die "Can't extract rocm tgz"
  fi
}

src_install() {
  if use amd64; then
    cp "${DISTDIR}/${P}.amd64" "${WORKDIR}/ollama"
  elif use arm64; then
    cp "${DISTDIR}/${P}.arm64" "${WORKDIR}/ollama"
  fi
  exeinto /opt/Ollama
  doexe "${WORKDIR}/ollama" || die "Failed to install binary"
  fperms +x /opt/Ollama/ollama
  dosym /opt/Ollama/ollama /opt/bin/ollama
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
      echo "ExecStart=/opt/Ollama/ollama serve"
      echo "User=ollama"
      echo "Group=ollama"
      echo "Restart=always"
      echo "RestartSec=3"
      echo ""
      echo "[Install]"
      echo "WantedBy=default.target"
    } > /etc/systemd/system/ollama.service
    einfo "Service file created at /etc/systemd/system/ollama.service"
    einfo "Making service user-startable..."
    mkdir -p /etc/systemd/user
    ln -s /etc/systemd/system/ollama.service /etc/systemd/user/ollama.service
  fi
}

