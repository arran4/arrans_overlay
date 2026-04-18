EAPI=8

DESCRIPTION="JetBrains Junie CLI, a lightweight database client"
HOMEPAGE="https://junie.jetbrains.com"
SRC_URI="
    amd64? ( https://github.com/JetBrains/junie/releases/download/${PV}/junie-release-${PV}-linux-amd64.zip -> ${P}-junie-release-${PV}-linux-amd64.zip )
    arm64? ( https://github.com/JetBrains/junie/releases/download/${PV}/junie-release-${PV}-linux-aarch64.zip -> ${P}-junie-release-${PV}-linux-aarch64.zip )
"

LICENSE="JetBrains-User-Agreement"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

RDEPEND="dev-java/openjdk"
BDEPEND="app-arch/unzip"

S="${WORKDIR}"

src_unpack() {
    if use amd64; then
        unpack "${P}-junie-release-${PV}-linux-amd64.zip"
    elif use arm64; then
        unpack "${P}-junie-release-${PV}-linux-aarch64.zip"
    fi
}

src_install() {
    # Install the main app directory into /opt/junie-bin
    dodir /opt/junie-bin
    cp -pPR junie-app "${ED}/opt/junie-bin/" || die "Failed to copy junie-app"

    # Ensure the binary is executable
    fperms +x /opt/junie-bin/junie-app/bin/junie

    # Create a wrapper or symlink in /opt/bin
    dodir /opt/bin
    dosym ../junie-bin/junie-app/bin/junie /opt/bin/junie

    # Install icon
    if [[ -f junie-app/lib/junie.png ]]; then
        insinto /usr/share/pixmaps
        newins junie-app/lib/junie.png junie.png
    fi
}
