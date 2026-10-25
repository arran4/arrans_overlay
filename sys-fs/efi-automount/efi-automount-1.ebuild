# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="On-demand systemd automount configuration for /efi"
HOMEPAGE="https://github.com/arran4/arrans_overlay"
SRC_URI=""
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="sys-apps/systemd"

# Verify the installation target's fstab, both early and before merge.
_require_fstab_entry() {
	local fstab="${EROOT%/}/etc/fstab"
	local spec target fstype options remainder

	[[ -r ${fstab} ]] || die "A readable ${fstab} with a /efi entry is required"

	while read -r spec target fstype options remainder || [[ -n ${spec} ]]; do
		[[ ${spec} == \#* || -z ${spec} ]] && continue
		if [[ ${target} == /efi && -n ${fstype} && -n ${options} ]]; then
			return 0
		fi
	done < "${fstab}"

	die "Refusing to install: ${fstab} has no active /efi filesystem entry"
}

pkg_pretend() {
	_require_fstab_entry
}

pkg_preinst() {
	_require_fstab_entry
}

src_install() {
	systemd_dounit "${FILESDIR}/efi.automount"
}

pkg_postinst() {
	elog "Installed efi.automount; it has NOT been enabled automatically."
	elog "For on-demand mounts, use 'noauto' on the /efi entry in /etc/fstab."
	elog "Do not also use x-systemd.automount there: the generated unit may supersede this unit."
	elog "After reviewing your fstab and current mounts, run:"
	elog "  systemctl daemon-reload"
	elog "  systemctl enable --now efi.automount"
	elog "Accessing /efi triggers its existing fstab-backed .mount unit."
	elog "systemd tries to unmount after 30 seconds idle; busy mounts remain mounted."
	elog "This is not an emerge-specific pre/post wrapper and does not restore an exact initial mount state."
}
