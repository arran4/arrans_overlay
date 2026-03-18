# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-gocdm-bin-update.yaml
EAPI=8
DESCRIPTION="The Console Display Manager (Go Port)"
HOMEPAGE="https://github.com/arran4/gocdm"
SRC_URI="
  amd64? (  https://github.com/arran4/gocdm/releases/download/v${PV}/gocdm_Linux_x86_64.tar.gz -> ${P}-gocdm_Linux_x86_64.tar.gz  )  
  arm64? (  https://github.com/arran4/gocdm/releases/download/v${PV}/gocdm_Linux_arm64.tar.gz -> ${P}-gocdm_Linux_arm64.tar.gz  )  
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
    unpack "${DISTDIR}/${P}-gocdm_Linux_x86_64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-gocdm_Linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "gocdm" "gocdm" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "gocdm" "gocdm" || die "Failed to install Binary"
  fi
}

pkg_postinst() {
  einfo "To autostart gocdm when you log in your account, append this to ~/.profile:"
  einfo "if [ -z \"\${DISPLAY:-}\" ] && [ \"\$(tty)\" = \"/dev/tty1\" ]; then"
  einfo "  exec /opt/bin/gocdm"
  einfo "fi"
  einfo ""
  einfo "To run GoCDM directly from tty1 under systemd, override getty@tty1.service:"
  einfo "sudo systemctl edit getty@tty1.service"
  einfo "Use this override:"
  einfo "[Service]"
  einfo "ExecStart="
  einfo "ExecStart=-/opt/bin/gocdm -login -pam-service login"
  einfo "StandardInput=tty"
  einfo "StandardOutput=tty"
  einfo "TTYPath=/dev/tty1"
  einfo "TTYReset=yes"
  einfo "TTYVHangup=yes"
  einfo "TTYVTDisallocate=yes"
  einfo ""
  einfo "Then reload and restart:"
  einfo "sudo systemctl daemon-reload"
  einfo "sudo systemctl restart getty@tty1.service"
  einfo ""
  einfo "Note: The binary release might not have PAM support compiled in."
  einfo "See https://github.com/arran4/gocdm for more details."
}
