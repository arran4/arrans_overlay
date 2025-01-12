# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="CUPS driver for Phomemo PM-246S series and other compatible label printers"
HOMEPAGE="https://phomemo.com"
SRC_URI="https://oss.saas.aimocloud.com/saas/Lablife/bag/LabelPrinter-1.2.1.tar.gz"

LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

S="${WORKDIR}/LabelPrinter-1.2.1"

src_prepare() {
    # Fix paths and permissions in the scripts if needed
    default
}

src_install() {
    local filter_path
    local ppd_path="/usr/share/ppd/pm-label-printer"

    # Determine architecture
    case ${ARCH} in
        amd64)
            filter_path="x86_64/rastertolabeltspl"
            ;;
        x86)
            filter_path="i386/rastertolabeltspl"
            ;;
        *)
            die "Unsupported architecture: ${ARCH}"
            ;;
    esac

    # Install CUPS filter
    exeinto /usr/libexec/cups/filter
    doexe "${S}/${filter_path}"

    # Install all PPD files
    insinto "${ppd_path}"
    doins ppds/*.ppd
}

pkg_postinst() {
    # Notify the user about the next steps
    elog "The PM label printer driver has been installed."
    elog "Supported models include:"
    elog "  - PM-241"
    elog "  - PM-246S"
    elog "  - PM-241-BT"
    elog "  - LabelPrinter242 (and variants)"
    elog "  - T200, T300, D520, D530, and others."
    elog
    elog "You may need to restart the CUPS service:"
    elog "  sudo /etc/init.d/cupsd restart"
    elog "Ensure your printer is configured using the appropriate PPD files located at:"
    elog "  /usr/share/ppd/pm-label-printer/"
}

