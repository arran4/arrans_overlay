EAPI=8

DESCRIPTION="Gemini CLI"
HOMEPAGE="https://github.com/google-gemini/gemini-cli"
SRC_URI="https://github.com/google-gemini/gemini-cli/releases/download/v${PV}/gemini-cli-bundle.zip -> ${P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=net-libs/nodejs-20.0.0 app-arch/unzip"
RDEPEND=">=net-libs/nodejs-20.0.0"

S="${WORKDIR}"

src_install() {
insinto /opt/${PN}
doins -r .

exeinto /opt/${PN}
doexe gemini.js

dosym ../../opt/${PN}/gemini.js /usr/bin/gemini
}
