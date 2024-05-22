EAPI=8

DESCRIPTION="Which Browser? A browser selecting tool with rules to automate."
HOMEPAGE="https://arran4.github.io/which_browser"
SRC_URI="https://desktop.ubels.online/~arran/which_browser/which_browser-linux-0.1.4-x86_64.deb"
LICENSE="Private"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
    unpack_deb which_browser-linux-${PV}-0.1.4-x86_64.deb
}

src_install() {
    # Install the contents of the deb package
    cp -r "${S}"/usr/* "${D}"/usr/
    cp -r "${S}"/opt/* "${D}"/opt/

    # Ensure the executable has the correct permissions
    fperms 0755 /opt/which_browser/which_browser

    # Create a symlink in /usr/bin for easy access
    dosym /opt/which_browser/which_browser /usr/bin/which_browser

    # Ensure the desktop file has the correct permissions
    if [[ -f "${D}/usr/share/applications/which_browser.desktop" ]]; then
        fperms 0644 /usr/share/applications/which_browser.desktop
    fi

    # Ensure the icon file has the correct permissions
    if [[ -f "${D}/usr/share/icons/hicolor/256x256/apps/icon.png" ]]; then
        fperms 0644 /usr/share/icons/hicolor/256x256/apps/icon.png
    fi
}

pkg_postinst() {
    einfo "Which Browser? has been installed."
}
