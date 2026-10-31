# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/net-im-beeper-appimage-update.yaml
EAPI=8
DESCRIPTION="Beeper universal chat app"
HOMEPAGE="https://www.beeper.com/"
SRC_URI="
	https://beeper-desktop.download.beeper.com/builds/Beeper-4.3.264-x86_64.AppImage ->
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
	chmod a+x "${P}.AppImage" || die "Cannot chmod archive file"
	exeinto /opt/bin
	newexe "${P}.AppImage" "beeper.AppImage" \
		|| die "Failed to install AppImage"
}
