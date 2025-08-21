# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-lang-dart-bin-update.yaml
EAPI=8
DESCRIPTION=" The Dart SDK, including the VM, dart2js, core libraries, and more."
HOMEPAGE="https://dart.dev/"
IUSE=""
SRC_URI="  
  amd64? ( https://storage.googleapis.com/dart-archive/channels/stable/release/${PV}/sdk/dartsdk-linux-x64-release.zip -> ${P}.amd64.zip )
  arm? ( https://storage.googleapis.com/dart-archive/channels/stable/release/${PV}/sdk/dartsdk-linux-arm-release.zip -> ${P}.arm.zip )
  arm64? ( https://storage.googleapis.com/dart-archive/channels/stable/release/${PV}/sdk/dartsdk-linux-arm64-release.zip -> ${P}.arm64.zip )
  riscv? ( https://storage.googleapis.com/dart-archive/channels/stable/release/${PV}/sdk/dartsdk-linux-riscv64-release.zip -> ${P}.riscv.zip )
" 
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv"
RDEPEND="app-arch/unzip"
DEPEND=""
S="${WORKDIR}/dart-sdk"

src_install() {
  mkdir "${ED}/opt" || die
  mv "${S}" "${ED}/opt/" || die
  
  dosym "/opt/dart-sdk/bin/dart" '/opt/bin/dart'
}

