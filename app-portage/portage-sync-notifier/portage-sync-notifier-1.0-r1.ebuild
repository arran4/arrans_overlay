EAPI=8

DESCRIPTION="A DBus notification agent for Portage sync, merge, fail, ask, depclean, and emerge completion"
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
	dobin "${FILESDIR}/portage-notifier"

	local hook
	for hook in postsync.d ebuild.postmerge.d ebuild.postfail.d \
		ask.d postdepclean.d postemerge.d; do
		dosym "../../../usr/bin/portage-notifier" \
			"/etc/portage/${hook}/portage-notifier"
	done
}

pkg_postinst() {
	elog "This package relies on non-standard Portage hooks provided by"
	elog "arran4's fork of Portage (PR #2). Ensure you are using a compatible version."
}
