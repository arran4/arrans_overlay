#!/usr/bin/env bash
# Shared ebuild generator for retained workflow recipes:
#   - app-misc/kjules
#   - app-misc/stability-matrix-appimage
#   - net-im/beeper-appimage
#
# Called by workflow update jobs and regression unit tests.

set -euo pipefail

usage() {
  cat << 'EOF' >&2
Usage: generate_retained_ebuild.sh <package> <ebuild_dir> <version> [args...]

Packages:
  kjules                     <ebuild_dir> <version>
  stability-matrix-appimage  <ebuild_dir> <version> [archived_name] [installed_name]
  beeper-appimage            <ebuild_dir> <version> [extension] [installed_name] [source_url]
EOF
  exit 1
}

if [ "$#" -lt 3 ]; then
  usage
fi

package="$1"
ebuild_dir="$2"
version="$3"
shift 3

mkdir -p "$ebuild_dir"

case "$package" in
  kjules|app-misc/kjules)
    ebuild_name="kjules"
    ebuild_file="${ebuild_dir}/${ebuild_name}-${version}.ebuild"

    # Revision guard: do not recreate if unrevisioned or -rN exists
    if [ -f "$ebuild_file" ] || compgen -G "${ebuild_dir}/${ebuild_name}-${version}-r[0-9]*.ebuild" > /dev/null; then
      echo "SKIPPED: ${ebuild_name}-${version} already exists in ${ebuild_dir}"
      exit 0
    fi

    description="${DESCRIPTION:-kjules KDE application}"
    homepage="${HOMEPAGE:-https://github.com/arran4/kjules}"
    github_owner="${GITHUB_OWNER:-arran4}"
    github_repo="${GITHUB_REPO:-kjules}"

    cat << EOF > "$ebuild_file"
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/app-misc-kjules-update.yaml
EAPI=8

ECM_TEST="forceoptional"
inherit xdg ecm

DESCRIPTION="${description}"
HOMEPAGE="${homepage}"
SRC_URI="
	https://github.com/${github_owner}/${github_repo}/archive/refs/tags/v\${PV}.tar.gz
		-> \${P}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

DEPEND="
	dev-qt/qtbase:6[gui,network,widgets]
	kde-frameworks/karchive:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kdbusaddons:6
	kde-frameworks/kglobalaccel:6
	kde-frameworks/ki18n:6
	kde-frameworks/knotifications:6
	kde-frameworks/kwallet:6
	kde-frameworks/kwidgetsaddons:6
	kde-frameworks/kwindowsystem:6
	kde-frameworks/kxmlgui:6
	test? (
		kde-frameworks/kcolorscheme:6
		kde-frameworks/kconfigwidgets:6
		kde-frameworks/kguiaddons:6
	)
"
RDEPEND="\${DEPEND}"

src_prepare() {
	ecm_src_prepare
	sed -i -e \\
		's/KDE_INSTALL_KXMLGUI6DIR/KDE_INSTALL_KXMLGUIDIR/g' \\
		CMakeLists.txt || die
	cmake_comment_add_subdirectory bench
}

src_configure() {
	ecm_src_configure
}
EOF
    echo "GENERATED: ${ebuild_file}"
    ;;

  stability-matrix-appimage|app-misc/stability-matrix-appimage)
    ebuild_name="stability-matrix-appimage"
    ebuild_file="${ebuild_dir}/${ebuild_name}-${version}.ebuild"

    # Revision guard: do not recreate if unrevisioned or -rN exists
    if [ -f "$ebuild_file" ] || compgen -G "${ebuild_dir}/${ebuild_name}-${version}-r[0-9]*.ebuild" > /dev/null; then
      echo "SKIPPED: ${ebuild_name}-${version} already exists in ${ebuild_dir}"
      exit 0
    fi

    archived_name="${1:-${StabilityMatrix_appimage_archived_name_amd64:-StabilityMatrix.AppImage}}"
    installed_name="${2:-${StabilityMatrix_appimage_installed_name:-StabilityMatrix.AppImage}}"
    description="${DESCRIPTION:-Multi-Platform Package Manager for Stable Diffusion}"
    homepage="${HOMEPAGE:-https://lykos.ai}"
    github_owner="${GITHUB_OWNER:-LykosAI}"
    github_repo="${GITHUB_REPO:-StabilityMatrix}"
    keywords="${KEYWORDS:-~amd64}"
    desktop_file="${StabilityMatrix_desktop_file:-zone.lykos.stabilitymatrix.desktop}"
    release_name="${StabilityMatrix_release_name_amd64:-StabilityMatrix-linux-x64.zip}"

    {
      cat << EOF
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/app-misc-stability-matrix-appimage-update.yaml
EAPI=8

inherit desktop xdg-utils

DESCRIPTION="${description}"
HOMEPAGE="${homepage}"
MY_URI="https://github.com/${github_owner}/${github_repo}/releases/download/v\${PV}"
SRC_URI="
	amd64? (
		\${MY_URI}/${release_name} ->
			\${P}-${release_name}
	)
"
S="\${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="${keywords}"
RESTRICT="strip"

RDEPEND="
	elibc_glibc? ( sys-libs/glibc )
	sys-devel/gcc
"
BDEPEND="app-arch/unzip"

pkg_pretend() {
	if ! use elibc_glibc; then
		die "Requires glibc; non-glibc profiles are unsupported."
	fi
}

src_unpack() {
	if use amd64; then
		unpack "\${P}-${release_name}" \\
			|| die "Cannot unpack archive file"
	fi
EOF

      # Rename guard: only emit mv when archived and installed names differ
      if [ "$archived_name" != "$installed_name" ]; then
        cat << EOF
	if use amd64; then
		mv "${archived_name}" "${installed_name}" || die "Cannot move archived file"
	fi
EOF
      fi

      cat << EOF
	chmod a+x "${installed_name}" || die "Cannot chmod archive file"
	"./${installed_name}" \\
		--appimage-extract "${desktop_file}" \\
		|| die "Failed to extract .desktop from appimage"
	"./${installed_name}" --appimage-extract "*.png" \\
		|| die "Failed to extract root icons from app image"
}

src_prepare() {
	sed -i \\
		's:^Exec=.*:Exec=/opt/bin/${installed_name}:' \\
		'squashfs-root/${desktop_file}' || die
	eapply_user
}

src_install() {
	exeinto /opt/bin
	doexe "${installed_name}" || die "Failed to install AppImage"
	domenu "squashfs-root/${desktop_file}"
	insinto /usr/share/pixmaps
	doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
	xdg_desktop_database_update
}
EOF
    } > "$ebuild_file"
    echo "GENERATED: ${ebuild_file}"
    ;;

  beeper-appimage|net-im/beeper-appimage)
    ebuild_name="beeper-appimage"
    ebuild_file="${ebuild_dir}/${ebuild_name}-${version}.ebuild"

    # Revision guard: do not recreate if unrevisioned or -rN exists
    if [ -f "$ebuild_file" ] || compgen -G "${ebuild_dir}/${ebuild_name}-${version}-r[0-9]*.ebuild" > /dev/null; then
      echo "SKIPPED: ${ebuild_name}-${version} already exists in ${ebuild_dir}"
      exit 0
    fi

    appimage_extension="${1:-${appimage_extension:-AppImage}}"
    installed_name="${2:-${beeper_appimage_installed_name:-beeper.AppImage}}"
    source_url="${3:-${BEEPER_APPIMAGE_URL:-https://beeper-desktop.download.beeper.com/builds/Beeper-${version}-x86_64.${appimage_extension}}}"
    description="${DESCRIPTION:-Beeper universal chat app}"
    homepage="${HOMEPAGE:-https://www.beeper.com/}"
    keywords="${KEYWORDS:-~amd64}"

    cat << EOF > "$ebuild_file"
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated via:
# .github/workflows/net-im-beeper-appimage-update.yaml
EAPI=8
DESCRIPTION="${description}"
HOMEPAGE="${homepage}"
SRC_URI="
	${source_url} ->
		\${P}.${appimage_extension}
"
S="\${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="${keywords}"
RESTRICT="strip"

src_install() {
	cp "\${DISTDIR}/\${P}.${appimage_extension}" "\${P}.${appimage_extension}" \\
		|| die "Failed to copy AppImage"
	chmod a+x "\${P}.${appimage_extension}" || die "Cannot chmod archive file"
	exeinto /opt/bin
	newexe "\${P}.${appimage_extension}" "${installed_name}" \\
		|| die "Failed to install AppImage"
}
EOF
    echo "GENERATED: ${ebuild_file}"
    ;;

  *)
    echo "Unknown package: $package" >&2
    exit 1
    ;;
esac
