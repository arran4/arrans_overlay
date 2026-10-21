# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/dev-lang-dart-bin-update.yaml
EAPI=8

DESCRIPTION="The Dart SDK, including the VM, dart2js, core libraries, and more"
HOMEPAGE="https://dart.dev/"

U="storage.googleapis.com/dart-archive/channels/stable/release/${PV}/sdk"
SRC_URI="
	amd64? ( https://${U}/dartsdk-linux-x64-release.zip -> ${P}.amd64.zip )
	arm? ( https://${U}/dartsdk-linux-arm-release.zip -> ${P}.arm.zip )
	arm64? ( https://${U}/dartsdk-linux-arm64-release.zip -> ${P}.arm64.zip )
	riscv? ( https://${U}/dartsdk-linux-riscv64-release.zip -> ${P}.riscv.zip )
"

# The SDK bundles Binaryen/LLVM/FP16, BoringSSL, ICU, Perfetto, RequireJS,
# double-conversion, and zlib in addition to Dart itself.
LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD MIT Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv"

RDEPEND="!dev-lang/dart"
BDEPEND="app-arch/unzip"

S="${WORKDIR}/dart-sdk"

src_install() {
	mkdir "${ED}/opt" || die
	mv "${S}" "${ED}/opt/" || die

	dosym "../dart-sdk/bin/dart" "/opt/bin/dart"
}
