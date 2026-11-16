# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 3877f94f0bd390f060784eb2d01998fac5ca1109
#   workflow: .github/workflows/www-apps-hugo-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="The world’s fastest framework for building websites."
HOMEPAGE=""
HOMEPAGE+="https://gohugo.io"
SRC_URI=""
SRC_URI+=" amd64? ( !extended? (   "
SRC_URI+="https://github.com/gohugoio/hugo/releases/download/v0.170.0/hugo_0.170.0_linux-amd64.tar.gz "
SRC_URI+=" -> ${P}-hugo_${PV}_linux-amd64.tar.gz  )  )   amd64? ( extended? (  "
SRC_URI+=" "
SRC_URI+="https://github.com/gohugoio/hugo/releases/download/v0.170.0/hugo_extended_0.170.0_Linux-64bit.tar.gz "
SRC_URI+=" -> ${P}-hugo_extended_${PV}_Linux-64bit.tar.gz  )  )   arm? (   "
SRC_URI+="https://github.com/gohugoio/hugo/releases/download/v0.170.0/hugo_0.170.0_linux-arm.tar.gz "
SRC_URI+=" -> ${P}-hugo_${PV}_linux-arm.tar.gz  )   arm64? ( !extended? (   "
SRC_URI+="https://github.com/gohugoio/hugo/releases/download/v0.170.0/hugo_0.170.0_linux-arm64.tar.gz "
SRC_URI+=" -> ${P}-hugo_${PV}_linux-arm64.tar.gz  )  )   arm64? ( extended? (  "
SRC_URI+=" "
SRC_URI+="https://github.com/gohugoio/hugo/releases/download/v0.170.0/hugo_extended_0.170.0_linux-arm64.tar.gz "
SRC_URI+=" -> ${P}-hugo_extended_${PV}_linux-arm64.tar.gz  )  )  "
LICENSE=""
LICENSE+="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE=""
IUSE+=" extended"

REQUIRED_USE=""
REQUIRED_USE+="extended? ( || ( amd64 arm64  ) ) "

RDEPEND=""
RDEPEND+="extended? ( sys-devel/gcc  ) "

S="${WORKDIR}"

src_unpack() {
	if use amd64 && ! use extended ; then
		unpack "${DISTDIR}/${P}-hugo_${PV}_linux-amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use amd64 && use extended; then
		unpack "${DISTDIR}/${P}-hugo_extended_${PV}_Linux-64bit.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-hugo_${PV}_linux-arm.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64 && ! use extended ; then
		unpack "${DISTDIR}/${P}-hugo_${PV}_linux-arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64 && use extended; then
		unpack "${DISTDIR}/${P}-hugo_extended_${PV}_linux-arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64 && ! use extended ; then
		newexe \
			"hugo" \
			"hugo" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"hugo" \
			"hugo" \
			|| die "Failed to install Binary"
	fi
	if use arm64 && ! use extended ; then
		newexe \
			"hugo" \
			"hugo" \
			|| die "Failed to install Binary"
	fi
	if use amd64 && use extended; then
		newexe \
			"hugo" \
			"hugo" \
			|| die "Failed to install Binary"
	fi
	if use arm64 && use extended; then
		newexe \
			"hugo" \
			"hugo" \
			|| die "Failed to install Binary"
	fi
}
