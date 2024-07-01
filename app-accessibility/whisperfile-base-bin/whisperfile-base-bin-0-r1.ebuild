# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-accessibility-whisperfiles-bin-update.yaml
EAPI=8
DESCRIPTION="Run whisper speach recognition base LLM in a single binary executable using llamafile."
HOMEPAGE="https://github.com/cjpais/whisperfile"
IUSE="systemd +full q5k q8 "
SRC_URI="amd64? ( 
  full? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.base.llamafile?download=true -> ${P}.amd64 )
  q5k? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.base.q5k.llamafile?download=true -> ${P}.q5k.amd64 )
  q8? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.base.q8.llamafile?download=true -> ${P}.q8.amd64 )
)"
LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND="acct-group/whisperfile acct-user/whisperfile"
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_unpack() {
    if use full; then
      cp "/${P}.amd64" 'whisper.base.llamafile' || die 'failed to move whisper.base.llamafile'
      chmod +x 'whisper.base.llamafile' || die 'failed to chmod whisper.base.llamafile'
    fi
    if use q5k; then
      cp "/${P}.${variant}.amd64" 'whisper.base.q5k.llamafile' || die 'failed to move whisper.base.q5k.llamafile'
      chmod +x 'whisper.base.q5k.llamafile' || die 'failed to chmod whisper.base.q5k.llamafile'
    fi
    if use q8; then
      cp "/${P}.${variant}.amd64" 'whisper.base.q8.llamafile' || die 'failed to move whisper.base.q8.llamafile'
      chmod +x 'whisper.base.q8.llamafile' || die 'failed to chmod whisper.base.q8.llamafile'
    fi
}

src_install() {
    exeinto /opt/bin
    if use full; then
      doexe "${WORKDIR}/whisper.base.llamafile"
    fi
    if use q5k; then
      doexe "${WORKDIR}/whisper.base.q5k.llamafile"
    fi
    if use q8; then
      doexe "${WORKDIR}/whisper.base.q8.llamafile"
    fi
}

pkg_postinst() {
    einfo "Quick guide:"
    if use full; then
      doexe "${WORKDIR}/whisper.base.llamafile"
      einfo "whisper.base.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile base full"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/whisper.base.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/whisperfile"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/whisper.base.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.base.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/whisper.base.llamafile.service /etc/systemd/system/whisper.base.llamafile.service
      ln -s /usr/lib/systemd/system/whisper.base.llamafile.service /etc/systemd/user/whisper.base.llamafile.service
      fi
    fi
    if use q5k; then
      doexe "${WORKDIR}/whisper.base.q5k.llamafile"
      einfo "whisper.base.q5k.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile base q5k"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/whisper.base.q5k.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/whisperfile"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/whisper.base.q5k.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.base.q5k.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/whisper.base.q5k.llamafile.service /etc/systemd/system/whisper.base.q5k.llamafile.service
      ln -s /usr/lib/systemd/system/whisper.base.q5k.llamafile.service /etc/systemd/user/whisper.base.q5k.llamafile.service
      fi
    fi
    if use q8; then
      doexe "${WORKDIR}/whisper.base.q8.llamafile"
      einfo "whisper.base.q8.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile base q8"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/whisper.base.q8.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/whisperfile"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/whisper.base.q8.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.base.q8.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/whisper.base.q8.llamafile.service /etc/systemd/system/whisper.base.q8.llamafile.service
      ln -s /usr/lib/systemd/system/whisper.base.q8.llamafile.service /etc/systemd/user/whisper.base.q8.llamafile.service
      fi
    fi
}

