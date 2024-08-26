# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="OpenDyslexic, a typeface that uses typeface shapes & features to help offset some visual symptoms of Dyslexia. Now in SIL-OFL."
HOMEPAGE="https://opendyslexic.org/"
SRC_URI="https://github.com/antijingoist/opendyslexic/releases/download/v${PV}/${PN}-0.910.12-rc2-2019.10.17.zip -> ${P}-rc2-2019.10.17.zip"

LICENSE="SIL OPEN FONT LICENSE"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE=""
S="${WORKDIR}"

RESTRICT="binchecks strip"

FONT_SUFFIX="otf woff2"
