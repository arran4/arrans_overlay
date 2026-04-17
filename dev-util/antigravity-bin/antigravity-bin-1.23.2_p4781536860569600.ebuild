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

SRC_URI="amd64? ( https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-x64/Antigravity.tar.gz -> ${P}.tar.gz )"

S="${WORKDIR}/Antigravity"

src_install() {
  insinto /opt/antigravity
  doins -r *
  fperms +x /opt/antigravity/antigravity
  fperms 4755 /opt/antigravity/chrome-sandbox
  fperms +x /opt/antigravity/chrome_crashpad_handler
  dosym ../antigravity/antigravity /opt/bin/antigravity
  newicon "resources/app/resources/linux/code.png" antigravity.png
  domenu "${FILESDIR}/antigravity-bin.desktop"
}
