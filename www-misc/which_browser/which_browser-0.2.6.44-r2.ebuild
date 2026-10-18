# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream changed their download host from arran4.sdf.org to
# https://which-browser-site.pages.dev, but the assets are returning 404.
# The GitHub repository arran4/which_browser is private, so we cannot fetch
# directly from GitHub Releases without authentication.
# This ebuild is marked with RESTRICT="fetch" until a public artifact hosting
# solution is implemented outside arrans_overlay.

DESCRIPTION="Which Browser? A browser selecting tool with rules to automate."
HOMEPAGE="https://which-browser-site.pages.dev"

MY_BASE_PV="0.2.6"
MY_BUILD_SUFFIX="44"

if [[ ${MY_BASE_PV} == ${PV} ]] || [[ -z ${MY_BUILD_SUFFIX} ]]; then
	die "Unexpected PV format: ${PV}"
fi

MY_DEB_ARCHIVE="which_browser-0.2.6+44-linux.deb"

# The following SRC_URI is currently broken (returns HTTP 404).
BASE_URL="https://which-browser-site.pages.dev/downloads/v0.2.6"
SRC_URI="${BASE_URL}/${MY_DEB_ARCHIVE}"
LICENSE="All-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="dev-util/patchelf"
RDEPEND="|| ( dev-libs/libayatana-appindicator )"
RESTRICT="mirror fetch"

S="${WORKDIR}"

inherit unpacker xdg

QA_PREBUILT="usr/share/which_browser/*"

pkg_nofetch() {
	einfo "Download URL is currently unavailable."
	einfo "The upstream repo is private and the host lacks files"
	einfo "serve the assets. This requires public artifact hosting"
	einfo "to be set up before it can be installed automatically."
	einfo "Please place \${MY_DEB_ARCHIVE} into DISTDIR manually."
}

src_prepare() {
	default
	chmod +w usr/share/which_browser/lib/libtray_manager_plugin.so || die
	patchelf --replace-needed libappindicator3.so.1 \
		libayatana-appindicator3.so.1 \
		usr/share/which_browser/lib/libtray_manager_plugin.so || die
}

src_unpack() {
	unpack_deb "${MY_DEB_ARCHIVE}"
}

src_install() {
	# Install the contents of the deb package
	cp -vr "${S}"/usr/ "${D}"/usr/

	# Ensure the executable has the correct permissions
	fperms 0755 /usr/share/which_browser/which_browser

	# Create a symlink in /usr/bin for easy access
	dosym ../share/which_browser/which_browser /usr/bin/which_browser

	# Ensure the desktop file has the correct permissions
	if [[ -f "${D}/usr/share/applications/which_browser.desktop" ]]; then
		fperms 0644 /usr/share/applications/which_browser.desktop
		sed -i -e '/^Version=/d' \
		"${D}/usr/share/applications/which_browser.desktop" || die
	fi

	# Ensure the icon file has the correct permissions
	if [[ -f "${D}/usr/share/icons/hicolor/256x256/apps/which_browser.png" ]]
	then
		fperms 0644 /usr/share/icons/hicolor/256x256/apps/which_browser.png
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
	einfo "Which Browser? has been installed."
	einfo "Please set it as the default HTTP and HTTPS handler."
}

pkg_postrm() {
	xdg_pkg_postrm
}
