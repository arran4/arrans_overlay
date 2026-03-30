# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-util-antigravity-bin-update.yaml
EAPI=8
inherit desktop
DESCRIPTION="Google Antigravity AI-driven IDE (binary release)"
HOMEPAGE="https://antigravity.google/"
LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND="sys-libs/glibc"
RESTRICT="strip"
QA_PREBUILT="opt/antigravity/antigravity opt/antigravity/chrome-sandbox"

SRC_URI="amd64? ( https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.21.6-5723021441368064/linux-x64/Antigravity.tar.gz -> ${P}.tar.gz )"

S="${WORKDIR}/Antigravity"

src_install() {
  insinto /opt/antigravity
  doins -r *
  fperms +x /opt/antigravity/antigravity
  fperms 4755 /opt/antigravity/chrome-sandbox
  dosym ../antigravity/antigravity /opt/bin/antigravity
  newicon "resources/app/resources/linux/code.png" antigravity.png
  domenu "${FILESDIR}/antigravity-bin.desktop"
}
