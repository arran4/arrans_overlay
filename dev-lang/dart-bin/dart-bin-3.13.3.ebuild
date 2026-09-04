# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# https://github.com/arran4/arrans_overlay/blob/main\
# /.github/workflows/dev-lang-dart-bin-update.yaml
EAPI=8

DESCRIPTION="The Dart SDK, including the VM, dart2js, core libraries, and more."
HOMEPAGE="https://dart.dev/"

U="storage.googleapis.com/dart-archive/channels/stable/release/${PV}/sdk"
SRC_URI="
	amd64? ( https://${U}/dartsdk-linux-x64-release.zip -> ${P}.amd64.zip )
	arm? ( https://${U}/dartsdk-linux-arm-release.zip -> ${P}.arm.zip )
	arm64? ( https://${U}/dartsdk-linux-arm64-release.zip -> ${P}.arm64.zip )
	riscv? ( https://${U}/dartsdk-linux-riscv64-release.zip -> ${P}.riscv.zip )
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv"

RDEPEND="app-arch/unzip"
S="${WORKDIR}/dart-sdk"

src_install() {
	mkdir "${ED}/opt" || die
	mv "${S}" "${ED}/opt/" || die

	dosym "../dart-sdk/bin/dart" "/opt/bin/dart"
}
