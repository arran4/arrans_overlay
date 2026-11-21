# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Official Epic Games Launcher native Linux Preview (AppImage)"
HOMEPAGE="https://launcher.epicgames.com/"
MY_BUILD="gc4bf6af"
MY_DISTFILE="${P}-${MY_BUILD}-x86_64.AppImage"
MY_APPIMAGE="EpicGamesLauncher.AppImage"
SRC_URI="https://content-download-egs.distro.on.epicgames.com/Builds/EGLv2/${PV}%2B${MY_BUILD}/Linux/EpicGamesLauncher-x86_64.AppImage -> ${MY_DISTFILE}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
  !games-util/epic-games-launcher
  sys-fs/fuse:0
  sys-libs/glibc
  x11-misc/xdg-utils
"

S="${WORKDIR}"

src_unpack() {
  cp "${DISTDIR}/${MY_DISTFILE}" "${S}/${MY_APPIMAGE}" ||
    die "Failed to copy AppImage"
  chmod +x "${S}/${MY_APPIMAGE}" || die

  # Extract only at build time to find bundled icons; keep the original
  # AppImage intact for execution and upstream package detection.
  "${S}/${MY_APPIMAGE}" --appimage-extract ||
    die "Failed to inspect AppImage"
}

src_install() {
  exeinto /opt/epic-games-launcher
  doexe "${MY_APPIMAGE}"
  newbin "${FILESDIR}/EpicGamesLauncher.sh" EpicGamesLauncher
  dosym EpicGamesLauncher /usr/bin/epic-games-launcher

  local icon="applications-games"
  if [[ -d "${S}/squashfs-root/usr/share/icons/hicolor" ]]; then
    insinto /usr/share/icons
    doins -r "${S}/squashfs-root/usr/share/icons/hicolor"
    icon="EpicGamesLauncher"
  fi
  make_desktop_entry EpicGamesLauncher "Epic Games Launcher (AppImage)" "${icon}" "Game;"
}

pkg_postinst() {
  xdg_pkg_postinst
  elog "This is an upstream Preview on an untested Gentoo distribution."
  elog "If browser sign-in fails on Plasma, inspect the AppImage's xdg-open handling."
}

pkg_postrm() {
  xdg_pkg_postrm
}
