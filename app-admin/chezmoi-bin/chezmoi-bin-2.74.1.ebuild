# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: f636b31688e92a368d73da0d0ef8c7c01d93294a
#   workflow: .github/workflows/app-admin-chezmoi-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Manage your dotfiles across multiple diverse machines, securely."
HOMEPAGE=""
HOMEPAGE+="https://www.chezmoi.io/"
SRC_URI=""
SRC_URI+=" amd64? ( glibc? ( !loong64? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux-glibc_amd64.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux-glibc_amd64.tar.gz  )  )  )   amd64? ( "
SRC_URI+="!glibc? ( !loong64? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux-musl_amd64.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux-musl_amd64.tar.gz  )  )  )   amd64? ( "
SRC_URI+="loong64? ( !glibc? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux_loong64.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux_loong64.tar.gz  )  )  )   arm? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux_armv6.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux_armv6.tar.gz  )   arm64? ( android? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_android_arm64.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_android_arm64.tar.gz  )  )   arm64? ( "
SRC_URI+="!android? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux_arm64.tar.gz  )  )   ppc64? ( !le? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux_ppc64.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux_ppc64.tar.gz  )  )   ppc64? ( le? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux_ppc64le.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux_ppc64le.tar.gz  )  )   riscv? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux_riscv64.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux_riscv64.tar.gz  )   s390? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux_s390x.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux_s390x.tar.gz  )   x86? (   "
SRC_URI+="https://github.com/twpayne/chezmoi/releases/download/v2.74.1/chezmoi_2.74.1_linux_i386.tar.gz "
SRC_URI+=" -> ${P}-chezmoi_${PV}_linux_i386.tar.gz  )  "
LICENSE=""
LICENSE+="MIT License"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~s390 ~x86"
IUSE=""
IUSE+=" android glibc le loong64"

REQUIRED_USE=""
REQUIRED_USE+="android? ( || ( arm64  ) ) glibc? ( || ( amd64  ) ) le? ( || ( "
REQUIRED_USE+="ppc64  ) ) loong64? ( || ( amd64  ) ) "

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64 && use glibc && ! use loong64 ; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux-glibc_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use amd64 && ! use glibc  && ! use loong64 ; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux-musl_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use amd64 && use loong64 && ! use glibc ; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_loong64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_armv6.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64 && use android; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_android_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64 && ! use android ; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use ppc64 && ! use le ; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_ppc64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use ppc64 && use le; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_ppc64le.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use riscv; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_riscv64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use s390; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_s390x.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use x86; then
		unpack "${DISTDIR}/${P}-chezmoi_${PV}_linux_i386.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use arm64 && use android; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use amd64 && ! use glibc  && ! use loong64 ; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use arm; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use arm64 && ! use android ; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use ppc64 && ! use le ; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use riscv; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use s390; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use x86; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use amd64 && use glibc && ! use loong64 ; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use ppc64 && use le; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
	if use amd64 && use loong64 && ! use glibc ; then
		newexe \
			"chezmoi" \
			"chezmoi" \
			|| die "Failed to install Binary"
	fi
}
