# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-lang-flutter-bin-update.yaml 
EAPI=8
DESCRIPTION="Flutter makes it easy and fast to build beautiful apps for mobile and beyond "
HOMEPAGE="https://flutter.dev/"
IUSE=""
SRC_URI="  
  amd64? ( 
    https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${PV}-stable.tar.xz -> ${P}.amd64.tar.xz
  )
" 
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND="app-arch/tar app-arch/xz-utils"
DEPEND=""
S="${WORKDIR}/flutter"

src_prepare() {
  # disable upgrade_flutter
	sed -i 's/^\(\s\+\)\(upgrade_flutter \)/\1# \2/' "${S}/bin/internal/shared.sh"
	eapply_user
}

src_install() {
  mkdir "${ED}/opt" || die
  mv "${S}" "${ED}/opt/" || die
  # TODO create a dart eselect
  dosym "/opt/flutter/bin/flutter" '/opt/bin/flutter'
}

