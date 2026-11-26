# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Akonadi resource exposing Gentoo eselect news as email"
HOMEPAGE="https://github.com/arran4/kmail-eselect-news"
SRC_URI="https://github.com/arran4/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1+ BSD-2 CC0-1.0 CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="kde-frameworks/extra-cmake-modules:0"

DEPEND="
	dev-qt/qtbase:6[dbus]
	kde-apps/akonadi:6=
	|| ( kde-frameworks/kmime:6 kde-apps/kmime:6 )
"
RDEPEND="
	${DEPEND}
	kde-apps/akonadi-mime:6
	sys-apps/portage
"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test ON OFF)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	dodoc -r screenshots LICENSES
}

pkg_postinst() {
	elog "Close KDE PIM applications, then run akonadictl restart as your desktop user."
	elog "In KMail, add the Gentoo News account under Settings > Accounts > Receiving."
	elog "The resource is read-only; it does not mark eselect news as read."
	elog "See https://github.com/arran4/kmail-eselect-news for usage and troubleshooting."
}
