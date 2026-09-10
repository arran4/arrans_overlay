# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="gRPC-Web code generator for Protocol Buffers"
HOMEPAGE="https://github.com/grpc/grpc-web"
SRC_URI="
	https://github.com/grpc/grpc-web/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
"
S="${WORKDIR}/grpc-web-${PV}/javascript/net/grpc/web/generator"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="dev-libs/protobuf[libprotoc(+)]"
DEPEND="${RDEPEND}"
BDEPEND="dev-libs/protobuf[protoc(+)]"

src_compile() {
	"$(tc-getCXX)" ${CPPFLAGS} ${CXXFLAGS} -std=c++11 -pthread \
		-c grpc_generator.cc -o grpc_generator.o || die
	"$(tc-getCXX)" ${CXXFLAGS} ${LDFLAGS} grpc_generator.o \
		-lprotoc -lprotobuf -pthread -ldl -o protoc-gen-grpc-web || die
}

src_test() {
	local grpc_web_opts="import_style=commonjs+dts,mode=grpcwebtext"
	mkdir "${T}/generated" || die
	"${BROOT}/usr/bin/protoc" \
		--plugin="protoc-gen-grpc-web=${S}/protoc-gen-grpc-web" \
		--proto_path="${FILESDIR}" \
		--grpc-web_out="${grpc_web_opts}:${T}/generated" \
		"${FILESDIR}/smoke.proto" || die
	grep -q 'SmokeClient' "${T}/generated/smoke_grpc_web_pb.js" || die
	[[ -s "${T}/generated/smoke_grpc_web_pb.d.ts" ]] || die
}

src_install() {
	dobin protoc-gen-grpc-web
	dodoc "${WORKDIR}/grpc-web-${PV}/README.md"
}
