EAPI=8

DESCRIPTION="A DBus notification agent for Portage sync completion"
HOMEPAGE="https://github.com/arran4/arrans_overlay"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	|| (
		x11-libs/libnotify
		kde-apps/kdialog
	)
	sys-apps/coreutils
"

S="${WORKDIR}"

src_install() {
	exeinto /etc/portage/postsync.d
	doexe "${FILESDIR}/portage-sync-notifier"
}
