# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/net-im-beeper-appimage-update.yaml
EAPI=8

DESCRIPTION="Unified chat client bridging multiple networks"
HOMEPAGE="https://www.beeper.com"
MY_URI="https://beeper-desktop.download.beeper.com/builds"
SRC_URI="
	${MY_URI}/Beeper-${PV}-x86_64.AppImage ->
		${P}.AppImage
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

src_install() {
	cp "${DISTDIR}/${P}.AppImage" "${P}.AppImage" \
		|| die "Failed to copy AppImage"
	chmod a+x "${P}.AppImage" || die "Can't chmod archive file"
	exeinto /opt/bin
	newexe "${P}.AppImage" "beeper.AppImage" \
		|| die "Failed to install AppImage"
}
