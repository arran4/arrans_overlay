# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

# m3shapes revision pinned in upstream CMakeLists.txt (fetched there via
# FetchContent git clone, which the Gentoo network sandbox forbids -- ship it
# as a tarball and point FetchContent at the unpacked dir instead).
M3SHAPES_REV="bdc327b29f95394a732baf3c9b19658ba23755b6"

DESCRIPTION="Caelestia Quickshell desktop shell (Hyprland)"
HOMEPAGE="https://github.com/caelestia-dots/shell"
SRC_URI="
	https://github.com/caelestia-dots/shell/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
	https://github.com/soramanew/m3shapes/archive/${M3SHAPES_REV}.tar.gz -> caelestia-m3shapes-${M3SHAPES_REV}.tar.gz
"
S="${WORKDIR}/shell-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

# Qt6 6.9+ (upstream: qt_standard_project_setup(REQUIRES 6.9)).
COMMON_DEPEND="
	>=dev-qt/qtbase-6.9:6[concurrent,dbus,gui,network,sql,widgets]
	>=dev-qt/qtdeclarative-6.9:6
	sci-libs/libqalculate
	media-libs/aubio
	media-video/pipewire
	media-sound/libcava
	sys-apps/lm-sensors
	sci-libs/fftw:3.0=
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="
	${COMMON_DEPEND}
	>=dev-qt/qtshadertools-6.9:6
	>=gui-apps/quickshell-0.3.0_p20260710
	gui-apps/caelestia-cli
	app-misc/ddcutil
	app-misc/brightnessctl
	app-shells/fish
	dev-libs/libxml2
	gui-apps/swappy
	gui-apps/wl-clipboard
	gui-wm/hyprland
	media-fonts/material-symbols-variable
	media-fonts/rubik
	media-fonts/cascadia-code
	media-fonts/noto
	media-fonts/noto-cjk
	media-fonts/noto-emoji
	net-misc/networkmanager
	sys-power/power-profiles-daemon
	sys-process/procps
	x11-libs/libnotify
	x11-misc/xkeyboard-config
"
BDEPEND="
	>=dev-qt/qtshadertools-6.9:6
	virtual/pkgconfig
"

PATCHES=(
	# Select one provider-neutral facial-authentication context and add Gaze
	# alongside the existing Howdy PAM backend.
	"${FILESDIR}/${PN}-configurable-facial-provider.patch"

	# Ignore transient no-main-keyboard gaps when deciding whether a valid
	# keyboard layout change should produce a notification.
	"${FILESDIR}/${PN}-ignore-transient-keyboard-layout-gaps.patch"

	# Add missing Qt includes (QObject, QVariant, QQmlEngine, QString, QTimer,
	# QPointer, QStringList) that upstream relied on transitively; Qt 6.11
	# dropped those transitive includes so the plugin fails to build without them.
	"${FILESDIR}/${PN}-qt6.11-includes.patch"

	# The Keep Awake idle inhibitor hangs off a PanelWindow built once inline
	# in a Singleton. A monitor hotplug destroys it and nothing rebuilds it, so
	# the toggle silently stops inhibiting while still reporting itself active.
	"${FILESDIR}/${PN}-rebuild-idle-inhibitor-window.patch"

	# Raise the notification's sender when its default action is invoked.
	# Windows carrying a focus_on_activate=false rule cannot raise themselves
	# (Wayland cannot distinguish an app's self-activation from a user click),
	# and the daemon is the only party that knows the click happened.
	"${FILESDIR}/${PN}-focus-sender-on-notification-action.patch"
)

src_configure() {
	local mycmakeargs=(
		# Upstream installs with prefix "/" and relative usr/... dests; the cmake
		# eclass defaults the prefix to /usr, which would yield /usr/usr/lib.
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/"
		# GOTCHA: Gentoo ships Qt6 QML under lib64; the upstream default
		# usr/lib/qt6/qml makes Quickshell fail with
		# \`module "Caelestia.Config" is not installed\`.
		-DINSTALL_QMLDIR=usr/lib64/qt6/qml
		# Release tarball has no .git, so upstream's git describe/rev-parse
		# fatal-errors -- supply version metadata explicitly.
		-DVERSION="${PV}"
		-DGIT_REVISION="v${PV}"
		-DDISTRIBUTOR="arrans_overlay"
		-DINSTALL_QSCONFDIR="usr/share/quickshell/caelestia"
		# Use the pre-fetched m3shapes source instead of a network git clone.
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_SOURCE_DIR_M3SHAPES_EXTERNAL="${WORKDIR}/m3shapes-${M3SHAPES_REV}"
	)
	cmake_src_configure
}

pkg_postinst() {
	elog "Caelestia shell installed. This replaces the manual"
	elog "cmake/ninja + 'cmake --install' workflow under ~/.config/quickshell/caelestia."
	elog
	elog "Your update-safe overrides in ~/.config/caelestia/ are NOT touched by"
	elog "this package: hypr-user.lua, hypr-vars.lua, user-config.fish, shell.json."
	elog
	elog "Launch with:  caelestia shell   (or: qs -p /usr/share/quickshell/caelestia)"
}
