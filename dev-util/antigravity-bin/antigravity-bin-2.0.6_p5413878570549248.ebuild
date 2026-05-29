# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-antigravity-bin-update.yaml
EAPI=8
inherit desktop
DESCRIPTION="Google Antigravity AI-driven IDE (binary release)"
HOMEPAGE="https://antigravity.google/"
LICENSE="Antigravity"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND="sys-libs/glibc"
RESTRICT="strip"
QA_PREBUILT="opt/antigravity/antigravity opt/antigravity/chrome-sandbox opt/antigravity/chrome_crashpad_handler"

SRC_URI="amd64? ( https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.6-5413878570549248/linux-x64/Antigravity.tar.gz -> ${PN}-${PV}.tar.gz )"

S="${WORKDIR}/Antigravity-x64"

BDEPEND="app-arch/asar"

src_prepare() {
	default
	asar extract-file resources/app.asar resources/linux/code.png "${WORKDIR}/icon.png" || die
}

src_install() {
  insinto /opt/antigravity
  doins -r *
  fperms +x /opt/antigravity/antigravity
  fperms 4755 /opt/antigravity/chrome-sandbox
  fperms +x /opt/antigravity/chrome_crashpad_handler
  dosym ../antigravity/antigravity /opt/bin/antigravity
  newicon "${WORKDIR}/icon.png" antigravity.png
  domenu "${FILESDIR}/antigravity-bin.desktop"
}
