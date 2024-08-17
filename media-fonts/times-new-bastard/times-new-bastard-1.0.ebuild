# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="It's Times New Roman but every seventh letter is jarringly sans serif"
HOMEPAGE="https://github.com/weiweihuanghuang/Times-New-Bastard"
SRC_URI="
	https://github.com/weiweihuanghuang/Times-New-Bastard/releases/download/v${PV}/TimesNewBastardv${PV}.zip -> ${P}.zip
"
S="${WORKDIR}"

LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86"
IUSE=""

RESTRICT="binchecks strip"

FONT_SUFFIX="otf"
