# Copyright 2024-2024 Arran Ubels
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="The 'Activate Windows' watermark ported to Linux"
HOMEPAGE="https://github.com/MrGlockenspiel/activate-linux"
BASE_URI="https://github.com/MrGlockenspiel/activate-linux"
SRC_URI="${BASE_URI}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui libconfig +wayland X"
REQUIRED_USE="|| ( wayland X ) X? ( gui )"

DEPEND="X? ( x11-libs/libX11 x11-libs/libXext x11-libs/libXfixes"
DEPEND+=" x11-libs/libXinerama x11-libs/libXrandr x11-libs/cairo"
DEPEND+=" x11-libs/pango )"
DEPEND+=" wayland? ( dev-libs/wayland x11-libs/cairo x11-libs/pango )"
DEPEND+=" libconfig? ( dev-libs/libconfig:= )"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"
BDEPEND+=" wayland? ( dev-util/wayland-scanner dev-libs/wayland-protocols )"

src_prepare() {
	default
}

set_myemakeargs() {
	local backends=()
	use wayland && backends+=( wayland )
	use X && backends+=( x11 )

	local addons=()
	use libconfig && addons+=( libconfig )

	myemakeargs=(
		CC="$(tc-getCC)"
		PREFIX="${EPREFIX}/usr"
		backends="${backends[*]}"
		with="${addons[*]}"
	)
}

src_compile() {
	set_myemakeargs
	emake "${myemakeargs[@]}"
}

src_install() {
	set_myemakeargs
	emake "${myemakeargs[@]}" MANDIR="${ED}/usr/share/man" \
		DESTDIR="${D}" install
}
