# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-antigravity-bin-update.yaml
EAPI=8
DESCRIPTION="Antigravity binary"
HOMEPAGE="https://antigravity.google/"
LICENSE="unknown"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=""
RDEPEND="sys-libs/glibc"
RESTRICT="strip"
QA_PREBUILT="opt/antigravity/antigravity opt/antigravity/chrome-sandbox"

SRC_URI="amd64? ( https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.20.5-5474622945755136/linux-x64/Antigravity.tar.gz -> \${P}.tar.gz )"

S="${WORKDIR}/Antigravity-linux-x64"

src_install() {
  insinto /opt/antigravity
  doins -r *
  fperms +x /opt/antigravity/antigravity
  fperms 4755 /opt/antigravity/chrome-sandbox
  dosym ../antigravity/antigravity /opt/bin/antigravity
}
