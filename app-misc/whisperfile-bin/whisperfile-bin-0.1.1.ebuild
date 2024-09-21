# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-whisperfile-bin-update.yaml
EAPI=8
DESCRIPTION="Distribute and run whisper LLMs with a single file."
HOMEPAGE="https://github.com/cjpais/whisperfile"
IUSE=""
SRC_URI="amd64? ( https://github.com/cjpais/whisperfile/releases/download/${PV}/whisperfile-${PV} -> ${P}.amd64 )"
LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_unpack() {
    mv "${A}" 'whisperfile'
    chmod +x 'whisperfile' or die 'failed to chmod whisperfile'
}

src_install() {
    exeinto /opt/bin
    doexe "${WORKDIR}/whisperfile"
}

