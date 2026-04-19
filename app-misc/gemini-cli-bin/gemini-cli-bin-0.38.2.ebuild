EAPI=8

DESCRIPTION="Gemini CLI"
HOMEPAGE="https://github.com/google-gemini/gemini-cli"
SRC_URI="https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-${PV}.tgz -> ${P}.tgz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=net-libs/nodejs-20.0.0"
RDEPEND="${DEPEND}"

S="${WORKDIR}/package"

src_install() {
	insinto /opt/${PN}
	doins -r bundle package.json

	exeinto /opt/${PN}/bundle
	doexe bundle/gemini.js

	dosym ../../opt/${PN}/bundle/gemini.js /usr/bin/gemini
}
