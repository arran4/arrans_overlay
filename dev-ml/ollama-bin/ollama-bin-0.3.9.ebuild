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
  amd64? ( https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-amd64.tgz  -> $P.amd64.tgz  )
  arm64? ( https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-arm64.tgz  -> $P.arm64.tgz  )
  rocm? ( https://github.com/ollama/ollama/releases/download/v${PV}/ollama-linux-amd64-rocm.tgz -> $P.rocm.tgz )
" 

src_unpack() {
  if use rocm; then
    tar -xzvf ${DISTDIR}/${P}.rocm.tgz -C '${WORKDIR}' || die "Can't extract rocm tgz"
  fi
  if use amd64; then
    tar -xzvf "${DISTDIR}/${P}.amd64.tgz" -C ${WORKDIR} || die "Failed to extract binary"
  elif use arm64; then
    tar -xzvf "${DISTDIR}/${P}.arm64.tgz" -C ${WORKDIR} || die "Failed to extract binary"
  fi
}

src_install() {
  exeinto /opt/Ollama/bin
  doexe "${WORKDIR}/bin/ollama" || die "Failed to install binary"
  libinto /opt/Ollama/lib/ollama/
  doexe -r "${WORKDIR}/lib/" || die "Failed to install binary"
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

