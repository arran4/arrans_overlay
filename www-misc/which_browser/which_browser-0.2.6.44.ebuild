EAPI=8

# Upstream changed their download host from arran4.sdf.org to
# https://which-browser-site.pages.dev, update SRC_URI accordingly.

DESCRIPTION="Which Browser? A browser selecting tool with rules to automate."
HOMEPAGE="https://which-browser-site.pages.dev"

MY_BASE_PV=${PV%.*}
MY_BUILD_SUFFIX=${PV##*.}

if [[ ${MY_BASE_PV} == ${PV} ]] || [[ -z ${MY_BUILD_SUFFIX} ]]; then
	die "Unexpected PV format: ${PV}"
fi

MY_DEB_ARCHIVE="${PN}-${MY_BASE_PV}+${MY_BUILD_SUFFIX}-linux.deb"

# Updated SRC_URI for new host structure: downloads/vBase/file
SRC_URI="https://which-browser-site.pages.dev/downloads/v${MY_BASE_PV}/${MY_DEB_ARCHIVE}"
LICENSE="All-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="|| ( dev-libs/libayatana-appindicator )"
RESTRICT="mirror"

# Verify the SHA256 checksum
S="${WORKDIR}"

inherit unpacker

src_unpack() {
	unpack_deb "${MY_DEB_ARCHIVE}"
}

src_install() {
	# Install the contents of the deb package
	# find .
	cp -vr "${S}"/usr/ "${D}"/usr/

	# Ensure the executable has the correct permissions
	fperms 0755 /usr/share/which_browser/which_browser

	# Create a symlink in /usr/bin for easy access
	dosym /usr/share/which_browser/which_browser /usr/bin/which_browser

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
