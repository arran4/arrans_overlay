# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Compiler and toolchain infrastructure library for WebAssembly"
HOMEPAGE="https://github.com/WebAssembly/binaryen"
BINARYEN_RELEASES="https://github.com/WebAssembly/binaryen/archive/refs/tags"
SRC_URI="
	${BINARYEN_RELEASES}/version_${PV}.tar.gz
		-> ${P}.tar.gz
"
S="${WORKDIR}/${PN}-version_${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=OFF
		-DENABLE_WERROR=OFF
		-DBUILD_STATIC_LIB=OFF
		-DINSTALL_LIBS=ON
	)
	cmake_src_configure
}

src_test() {
	local tools="${BUILD_DIR}/bin"
	"${tools}/wasm-as" "${FILESDIR}/smoke.wat" -o "${T}/smoke.wasm" || die
	"${tools}/wasm-opt" -Os "${T}/smoke.wasm" \
		-o "${T}/smoke-optimized.wasm" || die
	"${tools}/wasm-dis" "${T}/smoke-optimized.wasm" \
		-o "${T}/smoke-optimized.wat" || die
	grep -q '(export "answer"' "${T}/smoke-optimized.wat" || die
}
