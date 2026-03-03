EAPI=8

inherit go-module

DESCRIPTION="mpris media player command-line controller for vlc, mpv, RhythmBox, web browsers, cmus, mpd, spotify and others"
HOMEPAGE="https://github.com/arran4/go-playerctl"
SRC_URI="https://github.com/arran4/go-playerctl/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

EGO_SUM=(
	"github.com/godbus/dbus/v5 v5.0.4/go.mod h1:vr7zxjh//rA4w1KADbU8eS/+Y4b+N9Zc3A+zZgI0rEA="
	"github.com/godbus/dbus/v5 v5.1.0/go.mod h1:vr7zxjh//rA4w1KADbU8eS/+Y4b+N9Zc3A+zZgI0rEA="
	"github.com/godbus/dbus/v5 v5.2.2 h1:A/g0h6e5QYcW1b1hWw9fO8hUu115+0rN34O53XkYlYI="
	"github.com/godbus/dbus/v5 v5.2.2/go.mod h1:X1D/bO19Z2j6Hw7jWq0uYd3kU63y016A7JbZ22q5uH8="
	"golang.org/x/sys v0.27.0 h1:0Z9J0R7g+lK3bF6j9j5pE4/wW6B6N/vV8xY/v+jB5rQ="
	"golang.org/x/sys v0.27.0/go.mod h1:4/b99y8YxL/N1P/Hw+L2P7/vK7/qH1W9A9r2f6o3oQ="
)
go-module_set_globals

src_compile() {
	ego build -o go-playerctl ./cmd/playerctl
	ego build -o go-playerctld ./cmd/playerctld
}

src_install() {
	dobin go-playerctl
	dobin go-playerctld
}
