# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-accessibility-whisperfiles-bin-update.yaml
EAPI=8
DESCRIPTION="Run whisper speach recognition tiny LLM in a single binary executable using llamafile."
HOMEPAGE="https://github.com/cjpais/whisperfile"
IUSE="systemd +full q5k q8 "
SRC_URI="amd64? ( 
  full? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.tiny.llamafile?download=true -> ${P}.amd64 )
  q5k? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.tiny.q5k.llamafile?download=true -> ${P}.q5k.amd64 )
  q8? ( https://huggingface.co/cjpais/whisperfile/resolve/main/whisper.tiny.q8.llamafile?download=true -> ${P}.q8.amd64 )
)"
LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND="acct-group/whisperfile acct-user/whisperfile"
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_unpack() {
    if use full; then
      cp "${DISTDIR}/${P}.amd64" 'whisper.tiny.llamafile' || die 'failed to move whisper.tiny.llamafile'
      chmod +x 'whisper.tiny.llamafile' || die 'failed to chmod whisper.tiny.llamafile'
    fi
    if use q5k; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'whisper.tiny.q5k.llamafile' || die 'failed to move whisper.tiny.q5k.llamafile'
      chmod +x 'whisper.tiny.q5k.llamafile' || die 'failed to chmod whisper.tiny.q5k.llamafile'
    fi
    if use q8; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'whisper.tiny.q8.llamafile' || die 'failed to move whisper.tiny.q8.llamafile'
      chmod +x 'whisper.tiny.q8.llamafile' || die 'failed to chmod whisper.tiny.q8.llamafile'
    fi
}

src_install() {
    exeinto /opt/bin
    if use full; then
      doexe "${WORKDIR}/whisper.tiny.llamafile"
    fi
    if use q5k; then
      doexe "${WORKDIR}/whisper.tiny.q5k.llamafile"
    fi
    if use q8; then
      doexe "${WORKDIR}/whisper.tiny.q8.llamafile"
    fi
}

pkg_postinst() {
    einfo "Quick guide:"
    if use full; then
      doexe "${WORKDIR}/whisper.tiny.llamafile"
      einfo "whisper.tiny.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile tiny full"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/whisper.tiny.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/whisperfile"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/whisper.tiny.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.tiny.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/whisper.tiny.llamafile.service /etc/systemd/system/whisper.tiny.llamafile.service
      ln -s /usr/lib/systemd/system/whisper.tiny.llamafile.service /etc/systemd/user/whisper.tiny.llamafile.service
      fi
    fi
    if use q5k; then
      doexe "${WORKDIR}/whisper.tiny.q5k.llamafile"
      einfo "whisper.tiny.q5k.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile tiny q5k"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/whisper.tiny.q5k.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/whisperfile"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/whisper.tiny.q5k.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.tiny.q5k.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/whisper.tiny.q5k.llamafile.service /etc/systemd/system/whisper.tiny.q5k.llamafile.service
      ln -s /usr/lib/systemd/system/whisper.tiny.q5k.llamafile.service /etc/systemd/user/whisper.tiny.q5k.llamafile.service
      fi
    fi
    if use q8; then
      doexe "${WORKDIR}/whisper.tiny.q8.llamafile"
      einfo "whisper.tiny.q8.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=Whisperfile tiny q8"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/whisper.tiny.q8.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/whisperfile"
        echo "User=whisperfile"
        echo "Group=whisperfile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/whisper.tiny.q8.llamafile.service
      einfo "Service file created at /etc/systemd/system/whisper.tiny.q8.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/whisper.tiny.q8.llamafile.service /etc/systemd/system/whisper.tiny.q8.llamafile.service
      ln -s /usr/lib/systemd/system/whisper.tiny.q8.llamafile.service /etc/systemd/user/whisper.tiny.q8.llamafile.service
      fi
    fi
}

