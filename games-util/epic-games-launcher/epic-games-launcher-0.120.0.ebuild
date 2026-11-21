# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="Official Epic Games Launcher native Linux Preview (Debian binary)"
HOMEPAGE="https://launcher.epicgames.com/"
MY_BUILD="gc4bf6af"
MY_DISTFILE="${P}-${MY_BUILD}-x86_64.deb"
SRC_URI="https://content-download-egs.distro.on.epicgames.com/Builds/EGLv2/${PV}%2B${MY_BUILD}/Linux/EpicGamesLauncher-x86_64.deb -> ${MY_DISTFILE}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
  !games-util/epic-games-launcher-appimage
  dev-libs/glib:2
  dev-libs/libayatana-appindicator
  media-libs/gst-plugins-good:1.0
  net-libs/libsoup:3.0
  net-libs/webkit-gtk:4.1
  sys-apps/dbus
  sys-libs/glibc
  x11-libs/cairo
  x11-libs/gdk-pixbuf
  x11-libs/gtk+:3
  x11-libs/libX11
  x11-misc/xdg-utils
"

S="${WORKDIR}"
QA_PREBUILT="usr/lib/epic-games-launcher/bin/EpicGamesLauncher usr/lib/epic-games-launcher/libEOSSDK-Linux-Shipping.so"

src_unpack() {
  unpack_deb "${MY_DISTFILE}" || die "Failed to unpack upstream DEB"
}

src_install() {
  # Preserve the upstream binary and library layout. The binary expects
  # its shared objects relative to usr/lib/epic-games-launcher.
  exeinto /usr/lib/epic-games-launcher/bin
  doexe usr/bin/EpicGamesLauncher

  exeinto /usr/lib/epic-games-launcher
  doexe usr/lib/epic-games-launcher/libEOSSDK-Linux-Shipping.so

  insinto /usr/lib/epic-games-launcher/resources
  doins usr/lib/epic-games-launcher/resources/ThirdPartyNotices.txt

  # Match the RUNPATH layout used by the native executable.
  dosym .. /usr/lib/epic-games-launcher/lib/epic-games-launcher

  newbin "${FILESDIR}/EpicGamesLauncher.sh" EpicGamesLauncher
  dosym EpicGamesLauncher /usr/bin/epic-games-launcher

  domenu usr/share/applications/epic-games-launcher.desktop

  insinto /usr/share/icons
  doins -r usr/share/icons/hicolor
}

pkg_postinst() {
  xdg_pkg_postinst
  elog "This is an upstream Preview. Gentoo is not an officially tested distribution."
  elog "Some Windows-only games require a compatibility layer."
}

pkg_postrm() {
  xdg_pkg_postrm
}
