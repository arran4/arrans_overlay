EAPI=8

DESCRIPTION="mpris media player command-line controller for vlc, mpv, RhythmBox, web browsers, cmus, mpd, spotify and others"
MY_PN="${PN/-bin/}"

HOMEPAGE="https://github.com/arran4/go-playerctl"
SRC_URI="
	amd64? ( https://github.com/arran4/go-playerctl/releases/download/v${PV}/${MY_PN}_${PV}_linux_amd64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/arran4/go-playerctl/releases/download/v${PV}/${MY_PN}_${PV}_linux_arm64.tar.gz -> ${P}-arm64.tar.gz )
"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="!media-sound/go-playerctl"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_install() {
	newbin goplayerctl go-playerctl
	dosym go-playerctl /usr/bin/go-playerctld

	dodoc README.md COPYING
}
