EAPI=8

DESCRIPTION="Gemini CLI"
HOMEPAGE="https://github.com/google-gemini/gemini-cli"
SRC_URI="https://github.com/google-gemini/gemini-cli/releases/download/v0.43.0/gemini-cli-bundle.zip -> gemini-cli-bin-0.43.0.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
BDEPEND="app-arch/unzip"
RDEPEND=">=net-libs/nodejs-20.0.0"

S="${WORKDIR}"

src_install() {
insinto /opt/${PN}
doins -r *

fperms 0755 /opt/${PN}/gemini.js

dosym -r /opt/${PN}/gemini.js /usr/bin/gemini
}
