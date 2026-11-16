# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: dc0841aad6a8d7ee6b6e6238be14cd329c86ed14
#   workflow: .github/workflows/app-misc-tuios-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Terminal UI OS (Terminal Multiplexer)"
HOMEPAGE=""
HOMEPAGE+="https://github.com/Gaurav-Gosain/tuios"
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/Gaurav-Gosain/tuios/releases/download/v0.13.3/tuios_0.13.3_Linux_x86_64.tar.gz "
SRC_URI+=" -> ${P}-tuios_${PV}_Linux_x86_64.tar.gz  )   arm? (   "
SRC_URI+="https://github.com/Gaurav-Gosain/tuios/releases/download/v0.13.3/tuios_0.13.3_Linux_armv7.tar.gz "
SRC_URI+=" -> ${P}-tuios_${PV}_Linux_armv7.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/Gaurav-Gosain/tuios/releases/download/v0.13.3/tuios_0.13.3_Linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-tuios_${PV}_Linux_arm64.tar.gz  )   x86? (   "
SRC_URI+="https://github.com/Gaurav-Gosain/tuios/releases/download/v0.13.3/tuios_0.13.3_Linux_i386.tar.gz "
SRC_URI+=" -> ${P}-tuios_${PV}_Linux_i386.tar.gz  )  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-tuios_${PV}_Linux_x86_64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-tuios_${PV}_Linux_armv7.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-tuios_${PV}_Linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-tuios_${PV}_Linux_i386.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"tuios" \
			"tuios" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"tuios" \
			"tuios" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"tuios" \
			"tuios" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"tuios" \
			"tuios" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		dodoc "LICENSE" || die "Failed to install document LICENSE"
		dodoc "README.md" || die "Failed to install document README.md"
	fi
}
