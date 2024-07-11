# Copyright 2024 Arran Ubels <arran4@gmail.com>
# Distributed under the terms of the MIT License

EAPI=8

inherit cmake

DESCRIPTION="VLC plugin that adds 'seen' xattr tag to user.xdg.tags list when watching a video"
HOMEPAGE="https://github.com/arran4/vlc-xattr-plugin"
SRC_URI="https://github.com/arran4/vlc-xattr-plugin/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="media-video/vlc"
S="${WORKDIR}/vlc-xattr-plugin-1.0.1/"

src_prepare() {
	default
	cmake_src_prepare
}

src_configure() {
	cmake_src_configure
}

src_install() {
	# TODO give the cmake an install: cmake_src_install

	local vlc_plugin_dir="/usr/lib64/vlc/plugins/misc"
	dodir "${vlc_plugin_dir}"
	cp "${S}/lib/libxattrplaying_plugin.so" "${WORKDIR}/${vlc_plugin_dir}"
	doins "${WORKDIR}/${vlc_plugin_dir}/libxattrplaying_plugin.so" || die "Failed to install plugin"
}

