# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-ente-auth-appimage-update.yaml
EAPI=8
DESCRIPTION="Ente's 2FA solution"
HOMEPAGE="https://ente.io/blog/auth/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
BDEPEND="sys-fs/squashfs-tools"
DEPEND=""
RDEPEND="sys-libs/glibc sys-libs/zlib"
S="${WORKDIR}"
RESTRICT="strip"
QA_PREBUILT="opt/bin/ente_auth.AppImage"

inherit xdg-utils

SRC_URI="
  amd64? ( https://github.com/ente-io/ente/releases/download/auth-v4.4.18-beta/ente-auth-v4.4.18-beta-x86_64.AppImage -> ${P}-ente-auth-v4.4.18-beta-x86_64.AppImage )
"

src_unpack() {
  if use amd64; then
    cp "${DISTDIR}/${P}-ente-auth-v4.4.18-beta-x86_64.AppImage" "ente_auth.AppImage"  || die "Can't copy downloaded file"
  fi
  chmod a+x "ente_auth.AppImage"  || die "Can't chmod archive file"
  "./ente_auth.AppImage" --appimage-extract || die "Failed to extract appimage"
}

src_prepare() {
  sed -i 's:^Exec=.*:Exec=/opt/bin/ente_auth.AppImage:' 'squashfs-root/enteauth.desktop'
  find squashfs-root -type f \( -name index.theme -or -name icon-theme.cache \) -exec rm {} \; 
  find squashfs-root -type d -exec rmdir -p --ignore-fail-on-non-empty {} \; 
  rm "squashfs-root/usr/lib/libcrypto.so.3" || die "Failed to remove bundled libcrypto.so.3"
  rm "squashfs-root/usr/lib/libssl.so.3" || die "Failed to remove bundled libssl.so.3"
  local offset=$(./"ente_auth.AppImage" --appimage-offset) || die "Failed to get appimage offset"
  dd if="ente_auth.AppImage" of=appimage_runtime bs=1 count=$offset || die "Failed to extract appimage runtime"
  mksquashfs squashfs-root new.sqfs -root-owned -noappend -comp zstd || die "Failed to create new squashfs image"
  cat appimage_runtime new.sqfs > ente_auth_fixed.AppImage || die "Failed to create fixed appimage"
  chmod a+x ente_auth_fixed.AppImage || die "Failed to chmod fixed appimage"
  eapply_user
}

src_install() {
  exeinto /opt/bin
  newexe ente_auth_fixed.AppImage "ente_auth.AppImage" || die "Failed to install AppImage"
  insinto /usr/share/applications
  doins "squashfs-root/enteauth.desktop" || die "Failed to install desktop file"
  insinto /usr/share/icons
  doins -r squashfs-root/usr/share/icons/hicolor || die "Failed to install icons"
  insinto /usr/share/pixmaps
  doins squashfs-root/*.png || die "Failed to install icons"
}

pkg_postinst() {
  xdg_desktop_database_update
}

