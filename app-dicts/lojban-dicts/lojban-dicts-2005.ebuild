# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Lojban Text Dictionaries"
HOMEPAGE="https://mw-live.lojban.org/papri/lojban_Wordlists"
SRC_URI="
	https://www.lojban.org/publications/wordlists/cmavo.txt
	https://www.lojban.org/publications/wordlists/gismu.txt
	https://www.lojban.org/publications/wordlists/lujvo.txt
	https://www.lojban.org/publications/wordlists/rafsi.txt
"

LICENSE="public domain"
SLOT="0"
KEYWORDS="amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""
S="${DISTDIR}"

src_install() {
	insinto /usr/share/dict
	doins cmavo.txt gismu.txt lujvo.txt rafsi.txt
}
