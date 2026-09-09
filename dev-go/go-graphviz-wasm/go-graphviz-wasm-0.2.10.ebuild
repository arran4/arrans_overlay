# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 18 )

inherit llvm-r2

GRAPHVIZ_VERSION="12.1.2"
EXPAT_VERSION="2.6.3"

DESCRIPTION="Source-built Graphviz WebAssembly runtime for go-graphviz"
HOMEPAGE="https://github.com/goccy/go-graphviz"
GRAPHVIZ_RELEASES="https://gitlab.com/api/v4/projects/4207231/packages/generic"
GRAPHVIZ_DIST="${GRAPHVIZ_RELEASES}/graphviz-releases/${GRAPHVIZ_VERSION}"
EXPAT_RELEASES="https://github.com/libexpat/libexpat/releases/download"
SRC_URI="
	https://github.com/goccy/go-graphviz/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	${GRAPHVIZ_DIST}/graphviz-${GRAPHVIZ_VERSION}.tar.gz
	${EXPAT_RELEASES}/R_2_6_3/expat-${EXPAT_VERSION}.tar.gz
"
S="${WORKDIR}/go-graphviz-${PV}"

LICENSE="MIT CPL-1.0 Apache-2.0-with-LLVM-exceptions BSD-2 CC0-1.0"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	~dev-libs/wasi-sysroot-24.0
	~dev-util/binaryen-119
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/lld:${LLVM_SLOT}
	')
"

PATCHES=( "${FILESDIR}/${P}-build.patch" )

pkg_setup() {
	llvm-r2_pkg_setup
}

src_prepare() {
	default
	local rbtree="${WORKDIR}/graphviz-${GRAPHVIZ_VERSION}/lib/rbtree"
	rm "${rbtree}/test_red_black_tree.c" || die
}

src_configure() {
	local llvm_prefix=$(get_llvm_prefix -b)
	local wasi_root="${BROOT}/usr/share/wasi-sdk/24"
	local wasm_cc="${llvm_prefix}/bin/clang --target=wasm32-wasi"
	wasm_cc+=" --sysroot=${wasi_root}/share/wasi-sysroot"
	wasm_cc+=" -resource-dir=${wasi_root}/clang-resource-dir"

	(
		cd "${WORKDIR}/graphviz-${GRAPHVIZ_VERSION}" || die
		CC="${wasm_cc}" econf --host=amd64 --enable-ltdl=no \
			--with-ipsepcola=no
	) || die
	(
		cd "${WORKDIR}/expat-${EXPAT_VERSION}" || die
		CC="${wasm_cc}" econf --host=amd64
	) || die
}

src_compile() {
	local llvm_prefix=$(get_llvm_prefix -b)
	local build_dir="${S}/internal/wasm/build"
	(
		cd "${build_dir}" || die
		emake \
			CC="${llvm_prefix}/bin/clang" \
			WASI_SDK_ROOT="${BROOT}/usr/share/wasi-sdk/24" \
			GRAPHVIZ_ROOT="${WORKDIR}/graphviz-${GRAPHVIZ_VERSION}" \
			EXPAT_ROOT="${WORKDIR}/expat-${EXPAT_VERSION}" \
			build
	) || die
	wasm-opt -g --strip --strip-producers -c -Os \
		"${build_dir}/graphviz.wasm" \
		-o "${build_dir}/graphviz-optimized.wasm" || die
}

src_test() {
	local wasm="${S}/internal/wasm/build/graphviz-optimized.wasm"
	# wasm-opt validates the module while reading and writing it.
	wasm-opt "${wasm}" -o "${T}/validated.wasm" || die
	wasm-dis "${wasm}" -o "${T}/graphviz.wat" || die
	grep -q '(export "DeviceEngine_Initialize"' "${T}/graphviz.wat" || die
	grep -q '(export "agopen"' "${T}/graphviz.wat" || die
}

src_install() {
	insinto "/usr/share/go-graphviz/${PV}"
	newins internal/wasm/build/graphviz-optimized.wasm graphviz.wasm
	dodoc "${WORKDIR}/go-graphviz-${PV}/README.md" \
		"${WORKDIR}/go-graphviz-${PV}/LICENSE"
	docinto graphviz
	dodoc "${WORKDIR}/graphviz-${GRAPHVIZ_VERSION}/COPYING"
	docinto expat
	dodoc "${WORKDIR}/expat-${EXPAT_VERSION}/COPYING"
}
