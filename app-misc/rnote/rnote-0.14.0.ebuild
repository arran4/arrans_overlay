EAPI=8

inherit meson xdg desktop cargo

DESCRIPTION="Sketch and take handwritten notes."
HOMEPAGE="https://github.com/flxzt/rnote"
SRC_URI="https://github.com/flxzt/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/glib:2
	gui-libs/gtk:4
	gui-libs/libadwaita:1
	media-libs/alsa-lib
	dev-libs/appstream
	media-libs/gstreamer:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/gst-plugins-bad:1.0
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/meson
	dev-util/ninja
	sys-devel/clang
	virtual/pkgconfig
"

src_configure() {
	export CARGO_HOME="${ECARGO_HOME}"
	local emesonargs=(
		-Dprofile=default
		-Dcli=true
	)
	meson_src_configure
}
