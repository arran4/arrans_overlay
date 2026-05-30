# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/media-gfx-graphite-update.yaml
EAPI=8

inherit git-r3

DESCRIPTION="A lightweight raster and vector graphics editor in your browser."
HOMEPAGE="https://graphite.rs/"
EGIT_REPO_URI="https://github.com/GraphiteEditor/Graphite.git"
EGIT_COMMIT="master"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""

BDEPEND="
    net-libs/nodejs
    dev-lang/rust
    sys-apps/yarn
"
RDEPEND="dev-lang/python"

S="\${WORKDIR}/\${P}"

src_compile() {
    # Building Graphite from source is highly non-trivial due to npm dependencies and wasm-pack.
    # This is a best-effort compilation stub.
    # Users should prefer media-gfx/graphite-bin for a pre-compiled experience.
    yarn install || die
    npm run build || die
}

src_install() {
    insinto /opt/graphite
    doins -r frontend/dist/*

    cat > "\${T}/graphite" <<- 'SCRIPT_EOF'
    #!/bin/sh
    cd /opt/graphite
    echo "Starting Graphite editor on http://localhost:8080"
    exec python3 -m http.server 8080
    SCRIPT_EOF

    exeinto /usr/bin
    doexe "\${T}/graphite"
}
