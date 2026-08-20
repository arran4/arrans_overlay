# New ebuild for creating the ollama user

EAPI=8

inherit acct-user

DESCRIPTION="System user for ollama"
HOMEPAGE=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_USER_ID="-1"
ACCT_USER_GROUPS=( "ollama", "video" )
ACCT_USER_HOME="/opt/Ollama"
ACCT_USER_HOME_PERMS=755

acct-user_add_deps
