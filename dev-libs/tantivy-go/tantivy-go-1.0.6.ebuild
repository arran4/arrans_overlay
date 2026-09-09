# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.88.0"

# Generated from the packaged Cargo.lock using Python 3 tomllib.
CRATES="
	adler32@1.2.0
	aho-corasick@1.1.5
	allocator-api2@0.2.21
	anstream@1.0.0
	anstyle@1.0.14
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	arc-swap@1.9.2
	async-trait@0.1.92
	autocfg@1.5.1
	base64@0.22.1
	bitflags@1.3.2
	bitflags@2.13.1
	bitpacking@0.9.3
	bon@3.10.1
	bon-macros@3.10.1
	bumpalo@3.20.3
	byteorder@1.5.0
	cbindgen@0.28.0
	cc@1.4.5
	cedarwood@0.4.6
	census@0.4.2
	cfg-if@1.0.4
	clap@4.6.6
	clap_builder@4.6.6
	clap_lex@1.1.0
	colorchoice@1.0.5
	crc32fast@1.5.1
	crossbeam-channel@0.5.17
	crossbeam-deque@0.8.8
	crossbeam-epoch@0.9.21
	crossbeam-utils@0.8.23
	crunchy@0.2.2
	darling@0.24.1
	darling_core@0.24.1
	darling_macro@0.24.1
	dary_heap@0.3.9
	defmt@1.1.1
	defmt-macros@1.1.1
	defmt-parser@1.0.0
	deranged@0.5.8
	downcast-rs@2.0.2
	either@1.18.0
	env_filter@2.0.0
	env_logger@0.11.11
	equivalent@1.0.2
	errno@0.3.14
	fastdivide@0.4.2
	fastrand@2.5.0
	find-msvc-tools@0.1.12
	fnv@1.0.7
	foldhash@0.1.5
	foldhash@0.2.0
	fs4@0.8.4
	futures-core@0.3.34
	futures-macro@0.3.34
	futures-task@0.3.34
	futures-util@0.3.34
	fxhash@0.2.1
	getrandom@0.2.17
	getrandom@0.4.3
	hashbrown@0.15.5
	hashbrown@0.16.1
	hashbrown@0.17.1
	heck@0.4.1
	htmlescape@0.3.1
	hyperloglogplus@0.4.1
	ident_case@1.0.1
	include-flate@0.3.4
	include-flate-codegen@0.3.4
	include-flate-compress@0.3.4
	indexmap@2.14.2
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	itoa@1.0.18
	jieba-macros@0.7.1
	jieba-rs@0.7.4
	jiff@0.2.35
	jiff-core@0.1.0
	jiff-static@0.2.35
	jobserver@0.1.35
	js-sys@0.3.105
	lazy_static@1.5.0
	levenshtein_automata@0.2.1
	libc@0.2.189
	libflate@2.3.2
	libflate_lz77@2.3.0
	libm@0.2.16
	linux-raw-sys@0.4.15
	linux-raw-sys@0.12.1
	log@0.4.34
	logcall@0.1.13
	lru@0.12.5
	lz4_flex@0.11.6
	measure_time@0.9.0
	memchr@2.8.3
	memmap2@0.9.11
	minimal-lexical@0.2.1
	murmurhash32@0.3.1
	no_std_io2@0.9.4
	nom@7.1.3
	num-conv@0.2.2
	num-traits@0.2.19
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	oneshot@0.1.13
	phf@0.11.3
	phf_codegen@0.11.3
	phf_generator@0.11.3
	phf_macros@0.11.3
	phf_shared@0.11.3
	pin-project-lite@0.2.17
	pkg-config@0.3.34
	portable-atomic@1.15.0
	portable-atomic-util@0.2.8
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	prettyplease@0.3.0
	proc-macro-error-attr2@2.0.0
	proc-macro-error-attr3@3.1.1
	proc-macro-error2@2.0.1
	proc-macro-error3@3.1.1
	proc-macro2@1.0.107
	quote@1.0.47
	r-efi@6.0.0
	rand@0.8.8
	rand_chacha@0.3.1
	rand_core@0.6.4
	rand_distr@0.4.3
	rayon@1.12.0
	rayon-core@1.13.0
	regex@1.13.1
	regex-automata@0.4.18
	regex-syntax@0.8.11
	rle-decode-fast@1.0.3
	rustc-hash@2.1.3
	rustix@0.38.44
	rustix@1.1.4
	rustversion@1.0.23
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.151
	serde_spanned@0.6.9
	shlex@2.0.1
	siphasher@1.0.3
	sketches-ddsketch@0.3.1
	slab@0.4.12
	smallvec@1.16.0
	stable_deref_trait@1.2.1
	strsim@0.11.1
	syn@2.0.119
	syn@3.0.5
	tantivy-fst@0.5.0
	tempfile@3.27.0
	thiserror@2.0.20
	thiserror-impl@2.0.20
	time@0.3.55
	time-core@0.1.9
	time-macros@0.2.32
	toml@0.8.23
	toml_datetime@0.6.11
	toml_edit@0.22.27
	toml_write@0.1.2
	unicode-ident@1.0.24
	unicode-segmentation@1.13.3
	utf8-ranges@1.0.5
	utf8parse@0.2.2
	uuid@1.26.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasm-bindgen@0.2.128
	wasm-bindgen-macro@0.2.128
	wasm-bindgen-macro-support@0.2.128
	wasm-bindgen-shared@0.2.128
	winapi@0.3.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	windows-link@0.2.1
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.52.6
	winnow@0.7.15
	zerocopy@0.8.57
	zerocopy-derive@0.8.57
	zmij@1.0.23
	zstd@0.13.3
	zstd-safe@7.3.0
	zstd-sys@2.1.0+zstd.1.5.7
"

TANTIVY_COMMIT="693274a5d4be6da9d069dff4d540162165a99b0e"
TANTIVY_GIT="https://github.com/anyproto/tantivy;${TANTIVY_COMMIT}"
TANTIVY_CRATE="${TANTIVY_GIT};tantivy-%commit%"
JIEBA_GIT="https://github.com/anyproto/tantivy-jieba"
JIEBA_COMMIT="ca11d3153b8844cbc43cd243667e03f56f6d1e18"
STEMMERS_GIT="https://github.com/silver-ymz/rust-stemmers"
STEMMERS_COMMIT="51696378e352688b7ffd4fface615370ff5e8768"

declare -A GIT_CRATES=(
	[ownedbytes]="${TANTIVY_CRATE}/ownedbytes"
	[rust-stemmers]="${STEMMERS_GIT};${STEMMERS_COMMIT}"
	[tantivy]="${TANTIVY_CRATE}"
	[tantivy-bitpacker]="${TANTIVY_CRATE}/bitpacker"
	[tantivy-columnar]="${TANTIVY_CRATE}/columnar"
	[tantivy-common]="${TANTIVY_CRATE}/common"
	[tantivy-jieba]="${JIEBA_GIT};${JIEBA_COMMIT}"
	[tantivy-query-grammar]="${TANTIVY_CRATE}/query-grammar"
	[tantivy-sstable]="${TANTIVY_CRATE}/sstable"
	[tantivy-stacker]="${TANTIVY_CRATE}/stacker"
	[tantivy-tokenizer-api]="${TANTIVY_CRATE}/tokenizer-api"
)

inherit cargo

DESCRIPTION="Source-built Tantivy C library for the Anytype Go bindings"
HOMEPAGE="https://github.com/anyproto/tantivy-go"
SRC_URI="
	https://github.com/anyproto/${PN}/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${P}/rust"

# Includes licenses of the locked Rust dependencies. For dual-licensed crates,
# the MIT or Apache-2.0 option is used; rust-stemmers also includes BSD code.
LICENSE="MIT Apache-2.0 BSD BSD-2 MPL-2.0 Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	app-arch/gzip
	>=dev-lang/rust-1.88.0
"

src_prepare() {
	default
	gzip -dc "${FILESDIR}/${P}-Cargo.lock.gz" > Cargo.lock || die
	# Translate pinned Git sources to the local paths supplied by cargo.eclass.
	# Registry versions stay locked; only the declared crates are available.
	cargo_update_crates
}

src_configure() {
	cargo_src_configure --frozen --lib
}

src_test() {
	cargo_src_test
	# Also exercise the C ABI used by Heart, beyond the Rust unit tests.
	"$(tc-getCC)" ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -I.. \
		"${FILESDIR}/${PN}-smoke.c" \
		"$(cargo_target_dir)/libtantivy_go.a" \
		-ldl -lpthread -lm -o ffi-smoke || die
	./ffi-smoke || die "C ABI smoke test failed"
}

src_install() {
	# This crate exposes its C ABI only as a staticlib, consumed by cgo.
	dolib.a "$(cargo_target_dir)/libtantivy_go.a"
	insinto /usr/include/tantivy-go
	doins ../bindings.h ../binding_typedefs.h
	dodoc ../README.md ../LICENSE
}
