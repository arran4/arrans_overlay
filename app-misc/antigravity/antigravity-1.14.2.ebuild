EAPI=8

DESCRIPTION="The Antigravity application."
HOMEPAGE="https://edgedl.me.gvt1.com/"
SRC_URI="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.14.2-6046590149459968/linux-x64/Antigravity.tar.gz -> ${P}.tar.gz"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/Antigravity"

src_install() {
	insinto /opt/${PN}
	doins -r ./*
	dosym /opt/${PN}/antigravity /usr/bin/${PN}

	newicon "resources/app/out/media/code-icon.svg" "${PN}.svg"

	newmenu - << EOF
[Desktop Entry]
Name=Antigravity
Exec=/usr/bin/${PN}
Icon=${PN}
Type=Application
Categories=Utility;
EOF
}
