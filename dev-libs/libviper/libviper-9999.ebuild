EAPI=8

inherit cmake git-r3

DESCRIPTION="Ncurses widget toolkit used by VWM"
HOMEPAGE="https://github.com/TragicWarrior/libviper"
EGIT_REPO_URI="https://github.com/TragicWarrior/libviper.git"

LICENSE="GPL-2+"
SLOT="0/7"
KEYWORDS=""
IUSE="gpm static-libs"

RDEPEND="
	sys-libs/ncurses:0=[unicode]
	gpm? ( sys-libs/gpm )
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-9999-libdir.patch"
)

src_configure() {
	local mycmakeargs=(
		-DCMAKE_DISABLE_FIND_PACKAGE_GPM="$(usex gpm OFF ON)"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	if ! use static-libs; then
		rm "${ED}/usr/$(get_libdir)/libvdk.a" || die
	fi

	# Upstream's generated pkg-config file leaves includedir/libdir blank.
	# Install a usable system pkg-config description instead.
	local private_libs="-lncursesw"
	use gpm && private_libs+=" -lgpm"

	cat > "${T}/libviper.pc" <<-EOF || die
		prefix=${EPREFIX}/usr
		exec_prefix=\${prefix}
		libdir=\${prefix}/$(get_libdir)
		includedir=\${prefix}/include

		Name: libviper
		Description: A library for developing windowed apps on ncurses
		Version: 7.2.0
		Libs: -L\${libdir} -lvdk
		Libs.private: ${private_libs}
		Cflags: -I\${includedir}
	EOF
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${T}/libviper.pc"

	dodoc README.md CHANGELOG
}
