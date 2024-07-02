# New ebuild for creating the llamafile user

EAPI=8

inherit acct-user

DESCRIPTION="System user for llamafile"
HOMEPAGE=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_USER_ID="-1"
ACCT_USER_GROUPS=( "llamafile" )
ACCT_USER_HOME="/var/lib/llamafile/"

acct-user_add_deps
