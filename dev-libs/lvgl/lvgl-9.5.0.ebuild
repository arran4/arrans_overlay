EAPI=8

inherit cmake

DESCRIPTION="Light and Versatile Graphics Library"
HOMEPAGE="https://lvgl.io/ https://github.com/lvgl/lvgl"
SRC_URI="
	https://github.com/lvgl/lvgl/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
"

LICENSE="MIT"
SLOT="0/9"
KEYWORDS="~amd64"
IUSE="sdl"

RDEPEND="
	sdl? (
		media-libs/libsdl2[video]
	)
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-pkgconfig.patch"
	"${FILESDIR}/${P}-cmake-qa-notice.patch"
)

src_prepare() {
	cmake_src_prepare

	cp "${S}/lv_conf_template.h" "${S}/lv_conf.h" || die

	# Enable the contents of upstream's configuration template.
	sed -i \
		-e 's/^#if 0 \/\* Set this to "1" to enable content \*\//#if 1 \/\* Set this to "1" to enable content \*\//' \
		"${S}/lv_conf.h" || die

	if use sdl; then
		sed -i \
			-e 's/^#define LV_USE_SDL[[:space:]]\+0/#define LV_USE_SDL              1/' \
			"${S}/lv_conf.h" || die
	else
		sed -i \
			-e 's/^#define LV_USE_SDL[[:space:]]\+1/#define LV_USE_SDL              0/' \
			"${S}/lv_conf.h" || die
	fi
}

src_configure() {
	local pkgconfig_requires=""

	if use sdl; then
		pkgconfig_requires="sdl2"
	fi

	local mycmakeargs=(
		-DLV_BUILD_CONF_PATH="${S}/lv_conf.h"

		-DLV_BUILD_USE_KCONFIG=OFF
		-DLV_BUILD_SET_CONFIG_OPTS=OFF

		-DLV_BUILD_LVGL_H_SYSTEM_INCLUDE=ON
		-DLV_BUILD_LVGL_H_SIMPLE_INCLUDE=ON

		-DCONFIG_LV_BUILD_DEMOS=OFF
		-DCONFIG_LV_BUILD_EXAMPLES=OFF
		-DCONFIG_LV_USE_THORVG_INTERNAL=OFF

		-DBUILD_SHARED_LIBS=ON

		-DLIB_INSTALL_DIR="$(get_libdir)"
		-DINC_INSTALL_DIR="include/lvgl"
		-DRUNTIME_INSTALL_DIR="bin"

		-DLVGL_PKGCONFIG_REQUIRES="${pkgconfig_requires}"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	[[ -f "${ED}/usr/share/pkgconfig/lvgl.pc" ]] ||
		die "lvgl.pc was not installed"

	[[ -f "${ED}/usr/include/lvgl/lv_conf.h" ]] ||
		die "lv_conf.h was not installed"

	[[ -f "${ED}/usr/include/lvgl/lvgl.h" ]] ||
		die "lvgl.h was not installed"

	dodoc README.md
}
