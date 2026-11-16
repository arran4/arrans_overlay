# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: c2ebec79a5777e4ea4cd8379a7e2bab02955bf57
#   workflow: .github/workflows/media-sound-go-playerctl-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="mpris media player command-line controller for vlc, mpv, "
DESCRIPTION+="RhythmBox, web browsers, cmus, mpd, spotify and others"
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/go-playerctl"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/go-playerctl/releases/download/v0.0.23/go-playerctl_0.0.23_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-go-playerctl_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/go-playerctl/releases/download/v0.0.23/go-playerctl_0.0.23_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-go-playerctl_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
IUSE+=" doc man"

REQUIRED_USE=""

RDEPEND=""
RDEPEND+="!media-sound/go-playerctl "

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-go-playerctl_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-go-playerctl_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"goplayerctl" \
			"go-playerctl" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"goplayerctl" \
			"go-playerctl" \
			|| die "Failed to install Binary"
	fi
	if use man; then
		newman "doc/goplayerctl.1" "go-playerctl.1" || die "Failed to install manual page go-playerctl.1"
	fi
	if use doc; then
		dodoc "COPYING" || die "Failed to install document COPYING"
		dodoc "README.md" || die "Failed to install document README.md"
	fi
}
