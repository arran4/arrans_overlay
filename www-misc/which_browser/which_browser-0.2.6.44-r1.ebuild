EAPI=8

# Upstream changed their download host from arran4.sdf.org to
# https://which-browser-site.pages.dev, update SRC_URI accordingly.

DESCRIPTION="Which Browser? A browser selecting tool with rules to automate"
HOMEPAGE="https://which-browser-site.pages.dev"


# Updated SRC_URI for new host structure: downloads/vBase/file
# Hardcoded to prevent g2 static parsing errors with complex bash variables
SRC_URI="https://which-browser-site.pages.dev/downloads/v0.2.6/which_browser-0.2.6+44-linux.deb"
S="${WORKDIR}"
LICENSE="All-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-util/patchelf"
RDEPEND="|| ( dev-libs/libayatana-appindicator )"
RESTRICT="mirror"

inherit unpacker

src_prepare() {
	default
	chmod +w usr/share/which_browser/lib/libtray_manager_plugin.so || die
	patchelf --replace-needed libappindicator3.so.1 libayatana-appindicator3.so.1 \
		usr/share/which_browser/lib/libtray_manager_plugin.so || die
}

src_unpack() {
	unpack_deb "which_browser-0.2.6+44-linux.deb"
}

src_install() {
	# Install the contents of the deb package
	# find .
	cp -vr "${S}"/usr/ "${D}"/usr/

	# Ensure the executable has the correct permissions
	fperms 0755 /usr/share/which_browser/which_browser

	# Create a symlink in /usr/bin for easy access
	dosym ../share/which_browser/which_browser /usr/bin/which_browser

	# Ensure the desktop file has the correct permissions
	if [[ -f "${D}/usr/share/applications/which_browser.desktop" ]]; then
		fperms 0644 /usr/share/applications/which_browser.desktop
	fi

	# Ensure the icon file has the correct permissions
	if [[ -f "${D}/usr/share/icons/hicolor/256x256/apps/which_browser.png" ]]; then
		fperms 0644 /usr/share/icons/hicolor/256x256/apps/which_browser.png
	fi
}

pkg_postinst() {
	einfo "Which Browser? has been installed."

	einfo "Please set Which Browser? as the default HTTP and HTTPS handler."
}
