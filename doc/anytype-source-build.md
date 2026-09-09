# Anytype source build continuation

This work continues draft PR [#918](https://github.com/arran4/arrans_overlay/pull/918).
It is **not a working source package yet**. Do not merge until the complete source
chain, sandboxed Gentoo builds, and installed application have been validated.
The separate `anytype-ts-appimage` package is outside this work.

## Recovery audit (2026-09-09)

The checkout was clean on `feat/anytype-source-build` at
`d2ada7a79cfd482e2b55d556361a8258578ab4cf`, with no stashes or later Anytype
commits in the inspected branches/reflog. The ignored `scratch/test-heart`
directory contains an extracted Heart tree, a built `dist/server`, a populated
Go module cache, and `anytype-heart-0.51.0_rc7-deps.tar.xz`. These were preserved.
Its `go.mod` and `go.sum` match freshly fetched upstream release sources.
The binary is not evidence of a clean source build.

The recovered dependency archive includes
`golang.org/toolchain@v0.0.1-go1.26.5.linux-amd64` and must not be published or
declared as the source dependency archive unchanged. Use a legitimate Gentoo
Go build dependency and regenerate a toolchain-free, immutable module closure.

## Verified upstream inputs

* Desktop: [v0.56.9-alpha](https://github.com/anyproto/anytype-ts/tree/v0.56.9-alpha),
  Gentoo `0.56.9_alpha`.
* Heart: [v0.51.0-rc7](https://github.com/anyproto/anytype-heart/tree/v0.51.0-rc7),
  Gentoo `0.51.0_rc7`, commit
  `81345d8b3a059cfb67e5593bee68924f1f7aa6b3`, timestamp
  `2026-09-05T22:12:33Z`. Its `go.mod` requires Go 1.26.5.
* `licenses/ASAL` matches both releases' `LICENSE.md` after ignoring trailing
  whitespace. Transitive dependency licenses still need an audit.

## Heart

Revision r1 corrects the nonexistent `util/vcs.version` linker symbol to
`GitSummary`, `GitCommit`, and `BuildDate`, matching upstream's govvv semantics.
`-buildvcs=false` prevents recording unrelated checkout metadata. The helper
target remains `cmd/grpcserver`, output `dist/server`, installed as
`anytypeHelper`, with `nosigar nowatchdog` tags.

The large `go-module_set_globals` call is still unresolved. The Gentoo eclass
inspected during recovery reads the deprecated `EGO_SUM` array; it does **not**
consume the argument passed by this ebuild. Consequently this list currently
declares no module fetch inputs. Replace it with a supported dependency archive
mechanism, with reproducible generation and complete Manifest coverage. Do not
restore `EGO_SUM` or assume a successful metadata scan proves offline fetching.

Upstream `setup-network-config` uses the embedded production network by default;
custom build configurations copy `ANY_SYNC_NETWORK` and add `envnetworkcustom`.
An offline package must preserve the applicable semantics without importing
undeclared host files or invoking networked setup targets.

`check-tantivy-version` downloads native libraries. The new
`dev-libs/tantivy-go-1.0.6` ebuild provides a source-built static library and C
headers instead; Heart still needs to declare and integrate this dependency.
Its `rust/Cargo.toml` pins:

* `anyproto/tantivy`: `693274a5d4be6da9d069dff4d540162165a99b0e`.
* `anyproto/tantivy-jieba`: `ca11d3153b8844cbc43cd243667e03f56f6d1e18`.
* Tantivy's `silver-ymz/rust-stemmers` dependency:
  `51696378e352688b7ffd4fface615370ff5e8768`.

The default Go binding links `-ltantivy_go` from the library search path;
`tantivylocal` instead uses bundled `libs/` directories. The native ebuild uses
`cargo.eclass`, a packaged deterministic gzip of Cargo.lock, 198 registry
archives, and three pinned Git archives (11 workspace crates). Together with
the upstream library source, all 202 fetch inputs have Manifest entries.
The library's C ABI is static-only upstream; installing `libtantivy_go.a` is
intentional. The ebuild requires source-built Rust >=1.88.0.

The library built offline with Rust 1.88.0, all nine upstream Rust tests passed,
and a C program linked the resulting archive and created a schema through its
public headers. This C check is also part of the ebuild's test phase.
All 198 registry archives were checked against both the
Cargo.lock SHA256 and fetched Manifest SHA512. `pkgcheck` reports no findings.
`scripts/test_ebuilds.sh` passed its Gentoo fetch test for all 202 inputs in a
separate empty distfile directory. These checks do not yet establish a
successful Gentoo merge.

To update the native dependency closure, use a fresh upstream source tree,
generate Cargo.lock with Cargo, derive CRATES and GIT_CRATES from that lock and
`cargo metadata`, and save the lock with `gzip -n -9`. `cargo_update_crates`
converts only the declared Git source crates to local paths during preparation;
compilation and tests use `--frozen --lib`. Regenerate the complete Manifest
from the expanded Portage SRC_URI and metadata with `egencache`.

Heart's fresh Go-cache generation is underway separately from the preserved
recovery cache, with `GOTOOLCHAIN=local`. It must be verified and packaged before
replacing the ineffective module list. Audit embedded runtime artifacts too:
`go-graphviz` v0.2.10 embeds `internal/wasm/graphviz.wasm`, used by Heart's DOT
converter and debugging code. This must be rebuilt, not treated as an unused
fixture. Its upstream build uses Graphviz 12.1.2, Expat 2.6.3, WASI SDK 24, and
Binaryen 119. The WASM build Makefile is present in the upstream Git tag but
absent from the Go module zip, so the Git source archive is also needed.

## Frontend generation and dependencies

The Desktop compile/install phases remain placeholders. They are not evidence
of a successful package build or installation.

Desktop's `bun.lock` pins `ts-proto` 2.11.5. Its source generation requires:

1. The matching Heart `pb/protos/{commands,events,changes,snapshot}.proto` and
   `pkg/lib/pb/model/protos/{models,localstore}.proto`.
2. System `protoc`, the pinned ts-proto generator, and options
   `outputJsonMethods=false,initializeFieldsAsUndefined=false`.
3. Copying Desktop's `scripts/proto-overrides/struct.ts` over the generated
   `middleware/google/protobuf/struct.ts`.
4. Running `scripts/generate-service-registry.js` with `HEART_DIR` pointing to
   matching source protos, producing `src/ts/lib/api/service.ts`.

Do not invoke upstream `generate-protos.sh` unchanged: even its source mode runs
Heart's networked `make install-dev-js`. Do not use `--from-dist` or symlinks.
Heart's legacy JS/grpc-web generation and `system*.json`/`internal*.json` bundle
installation also remain to be packaged.

The exact JavaScript dependency closure still needs immutable fetch inputs and
offline assembly. In addition to runtime keytar, account for native build tools
such as SWC, esbuild, and the ts-proto -> ts-poet -> dprint-node dependency.
Disable download/install hooks and build the required native components from
source for their actual host or Electron ABI. Do not install preassembled
`node_modules` or downloaded `.node` files.

## Electron prerequisite

No compatible Electron source ebuild was found in the configured local Gentoo,
GURU, hyproverlay, or arrans-overlay repositories. Desktop requires `^41.10.6`.
[Electron v41.10.6 DEPS](https://github.com/electron/electron/blob/v41.10.6/DEPS)
pins Chromium `146.0.7680.216`, Node `v24.18.0`, and nan
`675cefebca42410733da8a454c8d9391fcebfbc2`.

The [Arch 41.10.6-1 source recipe](https://gitlab.archlinux.org/archlinux/packaging/packages/electron41/-/blob/41.10.6-1/PKGBUILD)
provides a concrete Linux porting reference with pinned recursive sources and
system toolchain build flags. It is not directly usable under Portage: its
prepare phase installs a Rust toolchain and updates npm dependencies. Replace
all such operations with declared fetch inputs and source dependencies, and
audit Chromium's build tools and precompiled inputs as well.

Create a separate prerequisite PR when a genuine source Electron implementation
exists. No Electron ebuild or prerequisite PR has been created yet. The Anytype
continuation must explicitly depend on it and stay draft until it builds.

## Completion gates

Still required: full Heart and Electron source dependency closures; source
frontend asset/middleware generation; offline JS installation; native rebuilds;
real Vite/Electron compilation; application resources, helper integration,
launcher, icons, desktop/protocol handling; dependency license audit; regenerated
metadata/Manifests; lint and clean sandboxed Gentoo builds; installed runtime
sanity checks proving the packaged runtime and helper are used.

The Debian host lacks `ebuild`; a separate Gentoo stage3 test root now runs
Portage. Its source merge of Tantivy is in progress, including source Rust
1.88.0 built with the standard older 1.87.0 compiler bootstrap. Kernel
restrictions permit only one mapped UID and reject nested proc mounts, so this
local root uses root-only execution and disables userpriv/userfetch/pid-sandbox.
Filesystem `sandbox` and `network-sandbox` remain enabled. A diagnostic through
Portage's process spawning confirmed a loopback-only build network and
`ENETUNREACH` for an external connection. Full CI with default privilege/PID
settings and installed application tests are still required.

Bash 5.2 makes pkgcore disable EAPI 9, hiding current Go ebuilds; Bash 5.3 was
built from source locally to run metadata checks against the current tree.
A focused offline check of upstream `util/vcs` using r1's actual linker arguments
returned the expected version, commit, and date; this covers version injection
only, not the full helper build.

Manifest verification exposed a parser bug: the script passed literal
`${PV/_rc/-rc}` expressions to g2 and returned success after fetch failures.
It now handles the literal prerelease substitutions used by both packages and
returns failure without rewriting a Manifest when any fetch fails. Both
upstream source archives were fetched and their Manifest entries regenerated;
this does not cover the still-undeclared dependency inputs. The 14 verifier
tests pass, including both package Manifests and failure-preservation checks.

`g2` v0.0.102's legacy lint command spends considerable time traversing Git
history before package checks. Running it from a source snapshot avoids that
overhead. It currently reports false unused-distfile errors for Cargo eclass
inputs, and looks for the unrevised Heart cache filename even though r1's
metadata is present. Do not remove declared crates or forge old cache entries
to silence these errors. The original Desktop/Heart formatting and incomplete
packaging findings also remain to be resolved.
