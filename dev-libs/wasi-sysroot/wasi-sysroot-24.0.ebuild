# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 18 )
PYTHON_COMPAT=( python3_{11..15} )

inherit cmake flag-o-matic llvm-r2 multiprocessing python-any-r1

# SDK release tags omit the .0 minor component.
MY_PV="24"
LLVM_COMMIT="26a1d6601d727a96f4301d0d8647b5a42760ae0c"
LIBC_COMMIT="b9ef79d7dbd47c6c5bafdae760823467c2f60b70"

DESCRIPTION="Source-built C and C++ runtime sysroot for wasm32-wasi"
HOMEPAGE="https://github.com/WebAssembly/wasi-sdk"
SRC_URI="
	https://github.com/WebAssembly/wasi-sdk/archive/wasi-sdk-${MY_PV}.tar.gz
	https://github.com/llvm/llvm-project/archive/${LLVM_COMMIT}.tar.gz
		-> llvm-project-${LLVM_COMMIT}.tar.gz
	https://github.com/WebAssembly/wasi-libc/archive/${LIBC_COMMIT}.tar.gz
		-> wasi-libc-${LIBC_COMMIT}.tar.gz
"
S="${WORKDIR}/wasi-sdk-wasi-sdk-${MY_PV}"

LICENSE="Apache-2.0-with-LLVM-exceptions MIT BSD-2 CC0-1.0"
SLOT="24"
KEYWORDS="~amd64"

BDEPEND="
	${PYTHON_DEPS}
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/lld:${LLVM_SLOT}
		llvm-core/llvm:${LLVM_SLOT}[llvm_targets_WebAssembly]
	')
"

PATCHES=( "${FILESDIR}/${PN}-24.0-source-archives.patch" )

pkg_setup() {
	python-any-r1_pkg_setup
	llvm-r2_pkg_setup
}

src_prepare() {
	rmdir src/llvm-project src/wasi-libc || die
	mv "${WORKDIR}/llvm-project-${LLVM_COMMIT}" src/llvm-project || die
	mv "${WORKDIR}/wasi-libc-${LIBC_COMMIT}" src/wasi-libc || die
	cmake_src_prepare
}

src_configure() {
	# These libraries target WebAssembly, not the machine running Portage.
	filter-flags '-m*' '-fstack-protector*' '-fcf-protection*'
	local llvm_prefix=$(get_llvm_prefix -b)
	cat > "${T}/wasi-sdk-VERSION" <<-EOF || die
		${PV}
		wasi-libc: ${LIBC_COMMIT}
		llvm: ${LLVM_COMMIT}
		llvm-version: 18.1.2
	EOF
	local mycmakeargs=(
		-DCMAKE_C_COMPILER="${llvm_prefix}/bin/clang"
		-DCMAKE_CXX_COMPILER="${llvm_prefix}/bin/clang++"
		-DCMAKE_AR="${llvm_prefix}/bin/llvm-ar"
		-DCMAKE_NM="${llvm_prefix}/bin/llvm-nm"
		-DPYTHON="${PYTHON}"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/share/wasi-sdk/${SLOT}"
		-DWASI_SDK_BUILD_TOOLCHAIN=OFF
		-DWASI_SDK_TARGETS=wasm32-wasi
		-DWASI_SDK_LTO=OFF
		-DWASI_SDK_INCLUDE_TESTS=OFF
		-DWASI_SDK_INSTALL_TO_CLANG_RESOURCE_DIR=OFF
		-DWASI_SDK_JOBS="$(makeopts_jobs)"
		-Dwasi_sdk_version="${PV}"
		-DWASI_SDK_VERSION_FILE="${T}/wasi-sdk-VERSION"
	)
	cmake_src_configure
}

src_compile() {
	# ExternalProject launches additional CMake and Make builds.
	export CMAKE_BUILD_PARALLEL_LEVEL=$(makeopts_jobs)
	cmake_src_compile
}

src_test() {
	local llvm_prefix=$(get_llvm_prefix -b)
	local flags=(
		--target=wasm32-wasi
		--sysroot="${BUILD_DIR}/install/share/wasi-sysroot"
		-resource-dir "${BUILD_DIR}/install/wasi-resource-dir"
	)
	"${llvm_prefix}/bin/clang" "${flags[@]}" \
		"${FILESDIR}/smoke.c" -o "${T}/smoke-c.wasm" || die
	# Upstream's WASI libc++ is built without exception support.
	"${llvm_prefix}/bin/clang++" "${flags[@]}" -fno-exceptions \
		"${FILESDIR}/smoke.cc" -o "${T}/smoke-cxx.wasm" || die
}

src_install() {
	cmake_src_install
	# The separate resource directory also needs Clang's builtin headers.
	insinto "/usr/share/wasi-sdk/${SLOT}/clang-resource-dir"
	doins -r "${BUILD_DIR}/install/wasi-resource-dir/include"
	dodoc README.md LICENSE
	docinto wasi-libc
	dodoc src/wasi-libc/LICENSE*
}
