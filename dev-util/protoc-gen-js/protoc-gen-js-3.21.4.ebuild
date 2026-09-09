# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

PROTOBUF_VERSION="27.1"

DESCRIPTION="Protocol Buffers JavaScript code generator built from source"
HOMEPAGE="https://github.com/protocolbuffers/protobuf-javascript"
PROTOBUF_JS_RELEASES="https://github.com/protocolbuffers/protobuf-javascript"
PROTOBUF_RELEASES="https://github.com/protocolbuffers/protobuf"
SRC_URI="
	${PROTOBUF_JS_RELEASES}/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	${PROTOBUF_RELEASES}/archive/refs/tags/v${PROTOBUF_VERSION}.tar.gz
		-> protobuf-${PROTOBUF_VERSION}.tar.gz
"
S="${WORKDIR}/protobuf-javascript-${PV}"

LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=dev-cpp/abseil-cpp-20230802:="
DEPEND="${RDEPEND}"
BDEPEND="dev-libs/protobuf[protoc(+)]"

src_prepare() {
	cp "${FILESDIR}/CMakeLists.txt" "${S}" || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=17
		-DJAVASCRIPT_SOURCE="${S}"
		-DPROTOBUF_SOURCE="${WORKDIR}/protobuf-${PROTOBUF_VERSION}"
	)
	cmake_src_configure
}

src_compile() {
	cmake_build protoc-gen-js
}

src_test() {
	mkdir "${T}/generated" || die
	"${BROOT}/usr/bin/protoc" \
		--plugin="protoc-gen-js=${BUILD_DIR}/protoc-gen-js" \
		--proto_path="${FILESDIR}" \
		--js_out="import_style=commonjs,binary:${T}/generated" \
		"${FILESDIR}/smoke.proto" || die
	grep -q 'proto.smoke.Node' "${T}/generated/smoke_pb.js" || die
}

src_install() {
	dobin "${BUILD_DIR}/protoc-gen-js"
	dodoc README.md LICENSE.md LICENSE-asserts.md
}
