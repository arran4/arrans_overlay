# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Temporary CI-only probe for PR #1046. Remove before merging.
EAPI=8

DESCRIPTION="Temporary Gentoo CI probe for log capture and progress"
HOMEPAGE="https://github.com/arran4/arrans_overlay"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}"

src_compile() {
	local i

	[[ -d ${T} && -w ${T} ]] || die "Build temp directory unavailable"

	# Sentinels belong only in archived logs, not the Actions console.
	printf '%s\n' "CI_ARCHIVE_ONLY_STDOUT_SENTINEL_1046"
	printf '%s\n' "CI_ARCHIVE_ONLY_STDERR_SENTINEL_1046" >&2
	for ((i = 0; i < 240; i++)); do
		printf 'CI_ARCHIVE_ONLY_VERBOSE_LINE_1046_%03d\n' "${i}"
	done

	# Exceed the monitor's 120-second heartbeat window in the sandbox.
	sleep 125 || die "Interrupted while exercising the heartbeat"

	printf '%s\n' 'Gentoo CI log probe complete' > "${T}/probe.txt" || die
}

src_install() {
	insinto "/usr/share/${PN}"
	doins "${T}/probe.txt" || die "Could not install CI log probe"
}
