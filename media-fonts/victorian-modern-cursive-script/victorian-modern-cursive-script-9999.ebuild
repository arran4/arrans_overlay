EAPI=8

inherit font

DESCRIPTION="Victorian Modern Cursive Script font - Handwriting Educational font"
HOMEPAGE="https://www.education.vic.gov.au/school/teachers/teachingresources/discipline/english/Pages/handwriting.aspx"
SRC_URI="https://www.education.vic.gov.au/Documents/school/teachers/teachingresources/discipline/english/vicmodcursive.zip -> vicmodcursive-${PV}.zip"
S="${WORKDIR}"

LICENSE="unknown-license"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc64 ~riscv x86"
IUSE=""

RESTRICT="binchecks strip"

FONT_SUFFIX="ttf"
