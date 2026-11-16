# SPDX-License-Identifier: MIT
# Generated via:
#   repository: https://github.com/arran4/arrans_overlay
#   commit: 2df80532797647d72353fd750347120a210ef97e
#   workflow: .github/workflows/app-misc-flutter-google-datastore-appimage-updat
#             e.yaml
EAPI=8
DESCRIPTION=""
DESCRIPTION+="Google Datastore and Datastore emulator client for \"easy\" "
DESCRIPTION+="modification of values"
HOMEPAGE=""
HOMEPAGE+="https://github.com/arran4/flutter_google_datastore"
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
SRC_URI+="https://github.com/arran4/flutter_google_datastore/releases/download/v0.1.46/flutter_google_datastore-0.1.46-linux.AppImage "
SRC_URI+=" -> ${P}-flutter_google_datastore-${PV}-linux.AppImage ) "

src_unpack() {
	if use amd64; then
		cp \
			"${DISTDIR}/${P}-flutter_google_datastore-0.1.46-linux.AppImage" \
			"flutter_google_datastore.AppImage" || die "Failed to copy downloaded file"
	fi
	chmod a+x "flutter_google_datastore.AppImage"  || die "Can't chmod archive file"
	"./flutter_google_datastore.AppImage" --appimage-extract "flutter_google_datastore.desktop" || die "Failed to extract .desktop from appimage"
	"./flutter_google_datastore.AppImage" --appimage-extract "usr/share/icons" || die "Failed to extract hicolor icons from app image"
	"./flutter_google_datastore.AppImage" --appimage-extract "*.png" || die "Failed to extract root icons from app image"
}

src_prepare() {
	sed -i 's:^Exec=.*:Exec=/opt/bin/flutter_google_datastore.AppImage:' 'squashfs-root/flutter_google_datastore.desktop'
	find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
	find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
	eapply_user
}

src_install() {
	exeinto /opt/bin
	doexe "flutter_google_datastore.AppImage" || die "Failed to install AppImage"
	insinto /usr/share/applications
	doins "squashfs-root/flutter_google_datastore.desktop" || die "Failed to install desktop file"
	insinto /usr/share/icons
	doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
	insinto /usr/share/pixmaps
	doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
	xdg_desktop_database_update
}

