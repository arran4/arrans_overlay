# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/media-gfx-graphite-bin-update.yaml
EAPI=8

DESCRIPTION="A lightweight raster and vector graphics editor in your browser."
HOMEPAGE="https://graphite.rs/"
SRC_URI="https://github.com/GraphiteEditor/Graphite/releases/download/latest-stable/graphite-self-hosted-build.zip -> \${P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"
RDEPEND="dev-lang/python"

S="\${WORKDIR}"

src_install() {
    insinto /opt/graphite
    doins -r graphite-*/*

    exeinto /usr/bin
    newexe "${FILESDIR}/graphite" graphite
}
