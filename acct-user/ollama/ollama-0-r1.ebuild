# New ebuild for creating the ollama user

EAPI=8

inherit acct-user

DESCRIPTION="System user for ollama"
HOMEPAGE=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

acct-user_pkg_setup() {
  enewgroup ollama
  enewuser ollama -1 -1 /usr/share/ollama ollama
}