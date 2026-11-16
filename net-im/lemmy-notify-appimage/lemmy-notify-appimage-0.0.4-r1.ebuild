# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 755a00d55f61ac8ea414c40cea7e109e98ec4f35
#   workflow: .github/workflows/net-im-lemmy-notify-appimage-update.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Lemmy Notification app - for desktop atm"
HOMEPAGE=""
LICENSE=""
LICENSE+="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND=""
RDEPEND+="sys-fs/fuse:0 sys-libs/glibc sys-libs/zlib"
S="${WORKDIR}"
RESTRICT="strip"

inherit xdg-utils

SRC_URI=""
SRC_URI+=" amd64? (  "
SRC_URI+="https://github.com/arran4/lemmy_notify/releases/download/v0.0.4/lemmy_notify-linux-x86_64.AppImage "
SRC_URI+=" -> ${P}-lemmy_notify-linux-x86_64.AppImage ) "

src_unpack() {
	if use amd64; then
		cp \
			"${DISTDIR}/${P}-lemmy_notify-linux-x86_64.AppImage" \
			"lemmy_notify.AppImage" || die "Failed to copy downloaded file"
	fi
	chmod a+x "lemmy_notify.AppImage"  || die "Can't chmod archive file"
	"./lemmy_notify.AppImage" --appimage-extract "lemmy_notify.desktop" || die "Failed to extract .desktop from appimage"
	"./lemmy_notify.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
	"./lemmy_notify.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
	sed -i 's:^Exec=.*:Exec=/opt/bin/lemmy_notify.AppImage:' 'squashfs-root/lemmy_notify.desktop'
	find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
	find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
	eapply_user
}

src_install() {
	exeinto /opt/bin
	doexe "lemmy_notify.AppImage" || die "Failed to install AppImage"
	insinto /usr/share/applications
	doins "squashfs-root/lemmy_notify.desktop" || die "Failed to install desktop file"
	insinto /usr/share/icons
	doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
	insinto /usr/share/pixmaps
	doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
	xdg_desktop_database_update
}

