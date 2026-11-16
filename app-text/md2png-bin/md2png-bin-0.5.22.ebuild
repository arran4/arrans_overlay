# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: d575d15fbb83dc3977b855c59c806c4314cf1266
#   workflow: .github/workflows/app-text-md2png-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Render Markdown directly to PNG or JPEG images with a single "
DESCRIPTION+="static Go binary."
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/md2png"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/md2png/releases/download/v0.5.22/md2png_0.5.22_Linux_x86_64.tar.gz "
SRC_URI+=" -> ${P}-md2png_${PV}_Linux_x86_64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/arran4/md2png/releases/download/v0.5.22/md2png_0.5.22_Linux_armv7.tar.gz "
SRC_URI+=" -> ${P}-md2png_${PV}_Linux_armv7.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/md2png/releases/download/v0.5.22/md2png_0.5.22_Linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-md2png_${PV}_Linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-md2png_${PV}_Linux_x86_64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-md2png_${PV}_Linux_armv7.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-md2png_${PV}_Linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"md2png" \
			"md2png" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"md2png" \
			"md2png" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"md2png" \
			"md2png" \
			|| die "Failed to install Binary"
	fi
}
