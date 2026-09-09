# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Build framework for desktop applications"
HOMEPAGE="https://electronjs.org/"
SRC_URI="https://github.com/electron/electron/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="41"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_compile() {
	einfo "Source build blocked pending massive chromium dependencies"
}

src_install() {
	einfo "Source install blocked pending build step"
}
