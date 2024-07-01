# New ebuild for creating the whisperfile user

EAPI=8

inherit acct-user

DESCRIPTION="System user for whisperfile"
HOMEPAGE=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

ACCT_USER_ID="-1"
ACCT_USER_GROUPS=( "whisperfile" )
ACCT_USER_HOME="/var/lib/whisperfile/"

acct-user_add_deps
