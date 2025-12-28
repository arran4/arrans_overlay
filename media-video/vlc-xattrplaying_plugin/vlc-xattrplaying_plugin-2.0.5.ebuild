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
RDEPEND="${DEPEND}"

S="${WORKDIR}/vlc-xattr-plugin-${PV}"
