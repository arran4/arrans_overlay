EAPI=8
DESCRIPTION="Ente's 2FA solution"
HOMEPAGE="https://ente.io/blog/auth/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
PROPERTIES="live"
IUSE=""
BDEPEND="sys-fs/squashfs-tools[zstd] net-misc/curl net-misc/jq"
DEPEND=""
RDEPEND="sys-libs/glibc sys-libs/zlib"
S="${WORKDIR}"
RESTRICT="strip network-sandbox"
QA_PREBUILT="opt/bin/ente_auth.AppImage"

inherit xdg-utils

src_unpack() {
  local tag=$(curl -s --header "Accept: application/vnd.github+json" https://api.github.com/repos/ente-io/ente/releases | jq -r '.[]? | select(type=="object" and has("tag_name") and (.tag_name | startswith("auth-v"))) | .tag_name' | head -n 1)
  if [[ -z "${tag}" ]]; then
      die "Failed to get latest release tag"
  fi

  local arch="x86_64"
  if use arm64; then arch="arm64"; fi
  local download_url="https://github.com/ente-io/ente/releases/download/${tag}/ente-${tag}-${arch}.AppImage"

  curl -sL -o "ente_auth.AppImage" "${download_url}" || die "Failed to download AppImage"
  chmod a+x "ente_auth.AppImage" || die "Can't chmod archive file"
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
