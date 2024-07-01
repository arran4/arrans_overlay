# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-accessibility-whisperfiles-bin-update.yaml
EAPI=8
DESCRIPTION="Run whisper speach recognition large-v3 LLM in a single binary executable using llamafile."
HOMEPAGE="https://github.com/cjpais/whisperfile"
IUSE="systemd +full q5k q8 "
SRC_URI="amd64? ( 
  full? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.large-v3.llamafile?download=true -> ${P}.amd64 )
  q5k? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.large-v3.q5k.llamafile?download=true -> ${P}.q5k.amd64 )
  q8? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.large-v3.q8.llamafile?download=true -> ${P}.q8.amd64 )
)"
LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_unpack() {
    if use full; then
      mv "${P}.amd64" 'whisper.large-v3.llamafile' or die 'failed to move whisper.large-v3.llamafile'
      chmod +x 'whisper.large-v3.llamafile' or die 'failed to chmod whisper.large-v3.llamafile'
    fi
    if use q5k; then
      mv "${P}.${variant}.amd64" 'whisper.large-v3.q5k.llamafile' or die 'failed to move whisper.large-v3.q5k.llamafile'
      chmod +x 'whisper.large-v3.q5k.llamafile' or die 'failed to chmod whisper.large-v3.q5k.llamafile'
    fi
    if use q8; then
      mv "${P}.${variant}.amd64" 'whisper.large-v3.q8.llamafile' or die 'failed to move whisper.large-v3.q8.llamafile'
      chmod +x 'whisper.large-v3.q8.llamafile' or die 'failed to chmod whisper.large-v3.q8.llamafile'
    fi
}

src_install() {
    exeinto /opt/bin
    if use full; then
      doexe "${WORKDIR}/whisper.large-v3.llamafile"
    fi
    if use q5k; then
      doexe "${WORKDIR}/whisper.large-v3.q5k.llamafile"
    fi
    if use q8; then
      doexe "${WORKDIR}/whisper.large-v3.q8.llamafile"
    fi
}

pkg_postinst() {
    einfo "Quick guide:"
    if use full; then
      doexe "${WORKDIR}/whisper.large-v3.llamafile"
      einfo "whisper.large-v3.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile large-v3 full"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/opt/bin/whisper.large-v3.llamafile  --host 0.0.0.0 --port 51524 --convert"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /etc/systemd/system/whisper.large-v3.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.large-v3.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /etc/systemd/system/whisper.large-v3.llamafile.service /etc/systemd/user/whisper.large-v3.llamafile.service
    fi
  fi
    einfo "Quick guide:"
    if use q5k; then
      doexe "${WORKDIR}/whisper.large-v3.q5k.llamafile"
      einfo "whisper.large-v3.q5k.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile large-v3 q5k"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/opt/bin/whisper.large-v3.q5k.llamafile  --host 0.0.0.0 --port 51524 --convert"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /etc/systemd/system/whisper.large-v3.q5k.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.large-v3.q5k.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /etc/systemd/system/whisper.large-v3.q5k.llamafile.service /etc/systemd/user/whisper.large-v3.q5k.llamafile.service
    fi
  fi
    einfo "Quick guide:"
    if use q8; then
      doexe "${WORKDIR}/whisper.large-v3.q8.llamafile"
      einfo "whisper.large-v3.q8.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile large-v3 q8"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/opt/bin/whisper.large-v3.q8.llamafile  --host 0.0.0.0 --port 51524 --convert"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /etc/systemd/system/whisper.large-v3.q8.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.large-v3.q8.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /etc/systemd/system/whisper.large-v3.q8.llamafile.service /etc/systemd/user/whisper.large-v3.q8.llamafile.service
    fi
  fi
}

