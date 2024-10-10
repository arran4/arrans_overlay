# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-moondream2-llamafile-bin-update.yaml
EAPI=8
DESCRIPTION="Run moondream2, a small vision language model designed to run efficiently on edge devices, in a single binary executable using llamafile."
HOMEPAGE="https://huggingface.co/cjpais/moondream2-llamafile"
IUSE="systemd q5_k q5km_050824 q8_050824 q8 +full "
SRC_URI="amd64? ( 
  q5_k? ( https://huggingface.co/cjpais/moondream2-llamafile/resolve/main/moondream2-q5_k.llamafile?download=true -> ${P}.q5_k.amd64 )
  q5km_050824? ( https://huggingface.co/cjpais/moondream2-llamafile/resolve/main/moondream2-q5km-050824.llamafile?download=true -> ${P}.q5km-050824.amd64 )
  q8_050824? ( https://huggingface.co/cjpais/moondream2-llamafile/resolve/main/moondream2-q8-050824.llamafile?download=true -> ${P}.q8-050824.amd64 )
  q8? ( https://huggingface.co/cjpais/moondream2-llamafile/resolve/main/moondream2-q8.llamafile?download=true -> ${P}.q8.amd64 )
  full? ( https://huggingface.co/cjpais/moondream2-llamafile/resolve/main/moondream2.llamafile?download=true -> ${P}.amd64 )
)"
LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND="systemd? ( acct-group/llamafile acct-user/llamafile )"
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_unpack() {
    if use q5_k; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'moondream2-q5_k.llamafile' || die 'failed to move moondream2-q5_k.llamafile'
      chmod +x 'moondream2-q5_k.llamafile' || die 'failed to chmod moondream2-q5_k.llamafile'
    fi
    if use q5km_050824; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'moondream2-q5km-050824.llamafile' || die 'failed to move moondream2-q5km-050824.llamafile'
      chmod +x 'moondream2-q5km-050824.llamafile' || die 'failed to chmod moondream2-q5km-050824.llamafile'
    fi
    if use q8_050824; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'moondream2-q8-050824.llamafile' || die 'failed to move moondream2-q8-050824.llamafile'
      chmod +x 'moondream2-q8-050824.llamafile' || die 'failed to chmod moondream2-q8-050824.llamafile'
    fi
    if use q8; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'moondream2-q8.llamafile' || die 'failed to move moondream2-q8.llamafile'
      chmod +x 'moondream2-q8.llamafile' || die 'failed to chmod moondream2-q8.llamafile'
    fi
    if use full; then
      cp "${DISTDIR}/${P}.amd64" 'moondream2.llamafile' || die 'failed to move moondream2.llamafile'
      chmod +x 'moondream2.llamafile' || die 'failed to chmod moondream2.llamafile'
    fi
}

src_install() {
    exeinto /opt/bin
    if use q5_k; then
      doexe "${WORKDIR}/moondream2-q5_k.llamafile"
    fi
    if use q5km_050824; then
      doexe "${WORKDIR}/moondream2-q5km-050824.llamafile"
    fi
    if use q8_050824; then
      doexe "${WORKDIR}/moondream2-q8-050824.llamafile"
    fi
    if use q8; then
      doexe "${WORKDIR}/moondream2-q8.llamafile"
    fi
    if use full; then
      doexe "${WORKDIR}/moondream2.llamafile"
    fi
}

pkg_postinst() {
    einfo "Quick guide:"
    if use q5_k; then
      doexe "${WORKDIR}/moondream2-q5_k.llamafile"
      einfo "moondream2-q5_k.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=llamafile moondream2 q5_k"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/moondream2-q5_k.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/llamafile"
        echo "User=llamafile"
        echo "Group=llamafile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/moondream2-q5_k.llamafile.service
      einfo "Service file created at /etc/systemd/system/moondream2-q5_k.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/moondream2-q5_k.llamafile.service /etc/systemd/system/moondream2-q5_k.llamafile.service
      ln -s /usr/lib/systemd/system/moondream2-q5_k.llamafile.service /etc/systemd/user/moondream2-q5_k.llamafile.service
      fi
    fi
    if use q5km_050824; then
      doexe "${WORKDIR}/moondream2-q5km-050824.llamafile"
      einfo "moondream2-q5km-050824.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=llamafile moondream2 q5km-050824"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/moondream2-q5km-050824.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/llamafile"
        echo "User=llamafile"
        echo "Group=llamafile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/moondream2-q5km-050824.llamafile.service
      einfo "Service file created at /etc/systemd/system/moondream2-q5km-050824.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/moondream2-q5km-050824.llamafile.service /etc/systemd/system/moondream2-q5km-050824.llamafile.service
      ln -s /usr/lib/systemd/system/moondream2-q5km-050824.llamafile.service /etc/systemd/user/moondream2-q5km-050824.llamafile.service
      fi
    fi
    if use q8_050824; then
      doexe "${WORKDIR}/moondream2-q8-050824.llamafile"
      einfo "moondream2-q8-050824.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=llamafile moondream2 q8-050824"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/moondream2-q8-050824.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/llamafile"
        echo "User=llamafile"
        echo "Group=llamafile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/moondream2-q8-050824.llamafile.service
      einfo "Service file created at /etc/systemd/system/moondream2-q8-050824.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/moondream2-q8-050824.llamafile.service /etc/systemd/system/moondream2-q8-050824.llamafile.service
      ln -s /usr/lib/systemd/system/moondream2-q8-050824.llamafile.service /etc/systemd/user/moondream2-q8-050824.llamafile.service
      fi
    fi
    if use q8; then
      doexe "${WORKDIR}/moondream2-q8.llamafile"
      einfo "moondream2-q8.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=llamafile moondream2 q8"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/moondream2-q8.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/llamafile"
        echo "User=llamafile"
        echo "Group=llamafile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/moondream2-q8.llamafile.service
      einfo "Service file created at /etc/systemd/system/moondream2-q8.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/moondream2-q8.llamafile.service /etc/systemd/system/moondream2-q8.llamafile.service
      ln -s /usr/lib/systemd/system/moondream2-q8.llamafile.service /etc/systemd/user/moondream2-q8.llamafile.service
      fi
    fi
    if use full; then
      doexe "${WORKDIR}/moondream2.llamafile"
      einfo "moondream2.llamafile --host 0.0.0.0 --port 51524 --convert -pc -pr -pp"
      einfo "curl 127.0.0.1:51524/inference -H \"Content-Type: multipart/form-data\" -F file=\"@<file-path>\"  -F temperature=\"0.0\"  -F temperature_inc=\"0.2\"  -F response_format=\"json\""
      if use systemd; then
      einfo "Creating systemd service file..."
      {
        echo "[Unit]"
        echo "Description=llamafile moondream2 full"
        echo "After=network-online.target"
        echo ""
        echo "[Service]"
        echo "ExecStart=/bin/bash -c '/opt/bin/moondream2.llamafile  --host 0.0.0.0 --port 51524 --convert'"
        echo "WorkingDirectory=/var/lib/llamafile"
        echo "User=llamafile"
        echo "Group=llamafile"
        echo "Restart=always"
        echo "RestartSec=3"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
      } > /usr/lib/systemd/system/moondream2.llamafile.service
      einfo "Service file created at /etc/systemd/system/moondream2.llamafile.service"
      einfo "Making service user-startable..."
      mkdir -p /etc/systemd/user
      ln -s /usr/lib/systemd/system/moondream2.llamafile.service /etc/systemd/system/moondream2.llamafile.service
      ln -s /usr/lib/systemd/system/moondream2.llamafile.service /etc/systemd/user/moondream2.llamafile.service
      fi
    fi
}

