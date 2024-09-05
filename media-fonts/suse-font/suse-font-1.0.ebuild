# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="SUSE is a sans serif typeface designed by René Bieder, embodying a unique hybrid between geometric and monospaced features. It captures the essence of SUSE, a company renowned for its open-source solutions."
HOMEPAGE="https://fonts.google.com/specimen/SUSE"
SRC_URI="
	https://github.com/SUSE/suse-font/releases/download/v1.000/suse-font-v1.000.zip -> ${P}.zip
"
LICENSE="MIT License"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE=""

RESTRICT="binchecks strip"

S="${WORKDIR}"

src_prepare() {
	mv -v ./suse-font-v1.000/fonts/*/*.{ttf,otf,woff2} .
	eapply_user
}

FONT_SUFFIX=" ttf otf woff2"
