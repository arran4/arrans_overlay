# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Mount guard and per-kernel recovery entries for systemd kernel-install"
HOMEPAGE="https://github.com/arran4/arrans_overlay"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+mount-guard +recovery"
REQUIRED_USE="|| ( mount-guard recovery )"

RDEPEND="
	sys-kernel/installkernel[systemd,systemd-boot]
	app-shells/bash
	sys-apps/coreutils
	sys-apps/util-linux
	sys-apps/gawk
	sys-apps/grep
"
BDEPEND="${RDEPEND}"

src_test() {
	bash "${FILESDIR}/test-hooks.sh" "${FILESDIR}" || die
}

src_install() {
	exeinto /usr/lib/kernel/install.d
	use mount-guard && doexe "${FILESDIR}/00-00-maintenance-mount.install"
	use recovery && doexe "${FILESDIR}/95-maintenance-recovery.install"
	dodoc "${FILESDIR}/README.md"
}

pkg_postinst() {
	elog "Hooks apply to subsequent kernel-install operations; no files are"
	elog "generated or removed by installing this package."
	elog "Review the installed README before migrating local recovery hooks."
}
