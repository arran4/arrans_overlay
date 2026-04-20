EAPI=8

DESCRIPTION="JetBrains Junie CLI, a lightweight database client"
HOMEPAGE="https://junie.jetbrains.com"
SRC_URI=""

LICENSE="JetBrains-User-Agreement"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

RDEPEND="virtual/jre"
BDEPEND="app-arch/unzip"

S="${WORKDIR}"


src_install() {
    # Install the main app directory into /opt/junie-bin
    dodir /opt/junie-bin
    cp -pPR junie-app "${ED}/opt/junie-bin/" || die "Failed to copy junie-app"

    # Ensure the binary is executable
    fperms +x /opt/junie-bin/junie-app/bin/junie

    # Create a wrapper or symlink in /opt/bin
    dosym ../../opt/junie-bin/junie-app/bin/junie /usr/bin/junie

    # Install icon
    if [[ -f junie-app/lib/junie.png ]]; then
        insinto /usr/share/pixmaps
        newins junie-app/lib/junie.png junie.png
    fi
}
