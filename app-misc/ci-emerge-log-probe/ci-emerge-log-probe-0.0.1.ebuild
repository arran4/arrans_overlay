# Temporary CI-only probe for PR #1046. Remove before merging.
EAPI=8

DESCRIPTION="Temporary Gentoo CI probe for complete log capture and concise progress"
HOMEPAGE="https://github.com/arran4/arrans_overlay"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}"

src_compile() {
    local i

    [[ -d ${T} && -w ${T} ]] || die "Sandbox-compatible build temp directory unavailable"

    # These sentinels must occur in the uploaded logs, NEVER in the normal
    # Actions console. Package-level emerge milestones should still appear.
    printf '%s\n' "CI_ARCHIVE_ONLY_STDOUT_SENTINEL_1046"
    printf '%s\n' "CI_ARCHIVE_ONLY_STDERR_SENTINEL_1046" >&2
    for ((i = 0; i < 240; i++)); do
        printf 'CI_ARCHIVE_ONLY_VERBOSE_LINE_1046_%03d\n' "${i}"
    done

    # Exceed the progress monitor's 120-second heartbeat window, without
    # needing source downloads, privileged operations or sandbox exceptions.
    sleep 125 || die "Interrupted while exercising the heartbeat"

    printf '%s\n' 'Gentoo CI log verification completed' > "${T}/probe.txt" || die
}

src_install() {
    insinto "/usr/share/${PN}"
    doins "${T}/probe.txt" || die "Could not install Gentoo CI log probe"
}
