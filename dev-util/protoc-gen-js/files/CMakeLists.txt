cmake_minimum_required(VERSION 3.16)
project(protoc_gen_js LANGUAGES C CXX)

set(protobuf_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_CONFORMANCE OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_PROTOC_BINARIES OFF CACHE BOOL "" FORCE)
set(protobuf_BUILD_LIBPROTOC ON CACHE BOOL "" FORCE)
set(protobuf_INSTALL OFF CACHE BOOL "" FORCE)
set(protobuf_WITH_ZLIB OFF CACHE BOOL "" FORCE)
set(protobuf_ABSL_PROVIDER package CACHE STRING "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

find_package(absl CONFIG REQUIRED)
add_subdirectory("${PROTOBUF_SOURCE}" protobuf)

add_executable(protoc-gen-js
	"${JAVASCRIPT_SOURCE}/generator/js_generator.cc"
	"${JAVASCRIPT_SOURCE}/generator/protoc-gen-js.cc"
	"${JAVASCRIPT_SOURCE}/generator/well_known_types_embed.cc"
)
target_include_directories(protoc-gen-js PRIVATE
	"${JAVASCRIPT_SOURCE}"
	"${PROTOBUF_SOURCE}/src"
)
target_link_libraries(protoc-gen-js PRIVATE
	protobuf::libprotoc
	protobuf::libprotobuf
	absl::strings
	absl::str_format
)
