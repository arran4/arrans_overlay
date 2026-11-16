# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 133ab94dd78670b49e3e0396bb11fa5633c40dc2
#   workflow: .github/workflows/app-misc-rntocase-bin-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Some utilities to rename files, to upper, lower, title, camel, "
DESCRIPTION+="kebab, darwin case and many more"
HOMEPAGE=""
SRC_URI=""
SRC_URI+=" amd64? (   "
SRC_URI+="https://github.com/arran4/rntocase/releases/download/v0.3.1/rntocase_0.3.1_linux_amd64.tar.gz "
SRC_URI+=" -> ${P}-rntocase_${PV}_linux_amd64.tar.gz  )   arm64? (   "
SRC_URI+="https://github.com/arran4/rntocase/releases/download/v0.3.1/rntocase_0.3.1_linux_arm64.tar.gz "
SRC_URI+=" -> ${P}-rntocase_${PV}_linux_arm64.tar.gz  )  "
LICENSE=""
LICENSE+="GNU General Public License v3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""
IUSE+=" doc"

REQUIRED_USE=""

RDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		unpack "${DISTDIR}/${P}-rntocase_${PV}_linux_amd64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
	if use arm64; then
		unpack "${DISTDIR}/${P}-rntocase_${PV}_linux_arm64.tar.gz" \
			|| die "Failed to unpack archive file"
	fi
}

src_install() {
	exeinto /opt/bin
	if use amd64; then
		newexe \
			"rnacronym" \
			"rnacronym" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rnacronym" \
			"rnacronym" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rnreverse" \
			"rnreverse" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rnreverse" \
			"rnreverse" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntocamel" \
			"rntocamel" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntocamel" \
			"rntocamel" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntodarwin" \
			"rntodarwin" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntodarwin" \
			"rntodarwin" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntodelimited" \
			"rntodelimited" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntodelimited" \
			"rntodelimited" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntokebab" \
			"rntokebab" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntokebab" \
			"rntokebab" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntolower" \
			"rntolower" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntolower" \
			"rntolower" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntolowerleading" \
			"rntolowerleading" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntolowerleading" \
			"rntolowerleading" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntopascal" \
			"rntopascal" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntopascal" \
			"rntopascal" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntosnake" \
			"rntosnake" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntosnake" \
			"rntosnake" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntotitle" \
			"rntotitle" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntotitle" \
			"rntotitle" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntoupper" \
			"rntoupper" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntoupper" \
			"rntoupper" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntoupperleading" \
			"rntoupperleading" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntoupperleading" \
			"rntoupperleading" \
			|| die "Failed to install Binary"
	fi
	if use amd64; then
		newexe \
			"rntrim" \
			"rntrim" \
			|| die "Failed to install Binary"
	fi
	if use arm64; then
		newexe \
			"rntrim" \
			"rntrim" \
			|| die "Failed to install Binary"
	fi
	if use doc; then
		if use amd64; then
			dodoc "LICENSE" || die "Failed to install document LICENSE"
			dodoc "LICENSE" || die "Failed to install document LICENSE"
		fi
	fi
}
