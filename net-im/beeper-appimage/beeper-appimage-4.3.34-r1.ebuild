# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/net-im-beeper-appimage-update.yaml
EAPI=8
DESCRIPTION="Unified chat client bridging multiple networks"
HOMEPAGE="https://www.beeper.com"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"
RESTRICT="strip"
SRC_URI="https://beeper-desktop.download.beeper.com/builds/Beeper-4.3.34-x86_64.AppImage -> ${P}.AppImage"

src_install() {
  cp "${DISTDIR}/${P}.AppImage" "${P}.AppImage" || die "Failed to copy AppImage"
  chmod a+x "${P}.AppImage" || die "Can't chmod archive file"
  exeinto /opt/bin
  newexe "${P}.AppImage" "beeper.AppImage" || die "Failed to install AppImage"
}
