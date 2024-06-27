# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/
EAPI=8
DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other large language models."
HOMEPAGE="https://ollama.com"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+systemd +rocm"
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI="  
  amd64? ( https://github.com/ollama/ollama/releases/download/${PV}/ollama-linux-amd64 -> $P.amd64 )
  arm64? ( https://github.com/ollama/ollama/releases/download/${PV}/ollama-linux-arm64 -> $P.arm64 )
  rocm? ( https://github.com/ollama/ollama/releases/download/${PV}/ollama-linux-amd64-rocm.tgz -> $P.rocm.tgz )
" 

pkg_setup() {
  enewgroup ollama
  enewuser ollama -1 -1 /usr/share/ollama ollama
}

src_unpack() {
  if use rocm; then
    tar -xzvf ${DISTDIR}/${P}.rocm.tgz -C ${WORKDIR} || die "Can't extract rocm tgz"
  fi
}

src_install() {
  if use amd64; then
    cp "${DISTDIR}/${P}.amd64" "${D}/opt/Ollama/ollama"
  elif use arm64; then
    cp "${DISTDIR}/${P}.arm64" "${D}/opt/Ollama/ollama"
  fi
  exeinto /opt/Ollama
  doexe "${D}/opt/Ollama/ollama" || die "Failed to install binary"
  fperms +x /opt/Ollama/ollama
  dosym /opt/Ollama/ollama /usr/bin/ollama
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
    cat <<EOF > /etc/systemd/system/ollama.service
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/opt/Ollama/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF
    einfo "Service file created at /etc/systemd/system/ollama.service"
  fi
}

