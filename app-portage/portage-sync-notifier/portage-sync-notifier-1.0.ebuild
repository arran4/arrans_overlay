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

	dosym ../../../usr/bin/portage-notifier /etc/portage/postsync.d/portage-notifier
	dosym ../../../usr/bin/portage-notifier /etc/portage/ebuild.postmerge.d/portage-notifier
	dosym ../../../usr/bin/portage-notifier /etc/portage/ebuild.postfail.d/portage-notifier
	dosym ../../../usr/bin/portage-notifier /etc/portage/ask.d/portage-notifier
	dosym ../../../usr/bin/portage-notifier /etc/portage/postdepclean.d/portage-notifier
	dosym ../../../usr/bin/portage-notifier /etc/portage/postemerge.d/portage-notifier
}

pkg_postinst() {
	elog "For events other than sync to be notified, this package requires"
	elog "the arran4 fork of portage with PR #2 merged:"
	elog "https://github.com/arran4/fork-portage/pull/2"
}
