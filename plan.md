1. **Analyze the Issue & Requirements**:
   - Issue: Transitive eclass inheritance isn't handled correctly when updating `INHERITED` metadata, nor in variables merged from those eclasses.
   - We need to correctly capture `INHERITED` across transitive eclasses, evaluate their variables, and merge them back into the ebuild when caching. However, reading the eclass variables statically could be incomplete. Wait, #544 is specifically about cache generation deriving `_eclasses_` / `_INHERITED` handling *only* from the ebuild's directly inherited eclasses.
   - "For an ebuild with `inherit ecm`, the generated metadata can contain only `ecm`, even though `ecm.eclass` itself inherits `cmake`, `flag-o-matic`, `toolchain-funcs`, `multiprocessing`, and potentially further eclasses."
   - Requirement: Resolve complete transitive eclass inheritance closure.
   - Wait, `eclassClosure` in `cache.go` recursively parses and visits eclasses: `func eclassClosure(...)`. It adds children:
     `for _, child := range strings.Fields(parsed.Vars["INHERITED"]) { if err := visit(child); err != nil { return err } }`
     Wait! The issue is that `cache.go` `GetExpectedCacheContent` formats `_eclasses_` successfully but it does *not* set the `INHERITED` cache metadata variable correctly!
     Wait, Portage expects `INHERITED` in the cache to contain the full transitive list. But currently `g2` probably just writes `ebuild.Vars["INHERITED"]`, which is only what the ebuild directly inherits.
     Also, let's check `ebuild.Vars["INHERITED"]`. The parsed ebuild only sets `INHERITED` from its own `inherit` calls!
     Let's check `cache.go` where `expectedContent` writes `ebuild.Vars[k]`:
     Ah, `v := ebuild.Vars[k]` ... so `INHERITED` is written with only direct inherits!

2. **Fix `INHERITED` Cache Metadata**:
   - In `GetExpectedCacheContent`, we get `eclassParts` from `eclassClosure`.
   - `eclassClosure` returns a list of strings formatted as `name\thash` in `ordered` output. Wait, `eclassClosure` currently returns `[]string` of `name\thash`. We could return both the `_eclasses_` list and the full space-separated list of inherited eclasses, or reconstruct it from `eclassParts`.
   - Let's check `eclassClosure`'s exact return values. It returns `result` which is `[]string` of `name\thash`.
   - Wait, the order of `_eclasses_` should match the order they were visited.
   - The cache variable `INHERITED` should contain the names of all inherited eclasses, separated by spaces.
   - Let's modify `eclassClosure` to also return the list of eclass names (without hashes), OR we can extract the names from `eclassParts` (by taking strings before `\t`).
   - Then, replace the value of `INHERITED` with the full sorted (or ordered?) list before writing `INHERITED`. Wait, does Portage expect `INHERITED` to be sorted, or ordered by inheritance? Ebuilds usually sort `INHERITED`, wait, no, Portage cache uses `INHERITED` space-separated, usually sorted. Let's verify standard Portage behavior.
