So #544 states:
"The concrete failure is that current cache generation derives `_eclasses_` / `INHERITED` handling only from the ebuild's directly inherited eclasses. For an ebuild with `inherit ecm`, the generated metadata can contain only `ecm`, even though `ecm.eclass` itself inherits `cmake`, `flag-o-matic`, ... "

Wait, `eclassClosure` seems to handle transitive inheritance for `_eclasses_` correctly, EXCEPT if the issue means `INHERITED` string itself doesn't contain the transitive list.
Let's check the test: `TestGenerateCacheTransitiveEclassesFromConfiguredMaster`.
It verifies `_eclasses_` contains both `first` and `second`.
But does it verify `INHERITED`?
```go
	want := fmt.Sprintf("_eclasses_=second\t%x\tfirst\t%x\n", md5.Sum(second), md5.Sum(first))
	if !strings.Contains(string(cache), want) {
```
Yes, `_eclasses_` contains both. So `_eclasses_` generation DOES traverse transitively.
Then what is the failure?
"Ensure `INHERITED`/related generated cache metadata is consistent with the complete resolved inheritance set where Portage cache semantics require it."
And:
"For an ebuild with inherit ecm, the generated metadata can contain only ecm, even though ecm.eclass itself inherits ... Portage expects cache metadata based on the complete applicable eclass dependency set"

Wait! Let me look closer at `cache.go:376`, `GetExpectedCacheContent`.
It resolves `eclassClosure` *at the bottom*! (lines 422-429).
But it loops through `keys` (which includes `INHERITED` because it's part of `ebuild.Vars`) *earlier* (lines 388-413)!
So the cache contains `INHERITED=first` (from `keys` loop), and `_eclasses_=second <hash> first <hash>`!
Portage sees `INHERITED=first` and complains about a QA Notice because Portage's evaluation actually says `INHERITED=first second`?
Yes!

The fix is straightforward:
We must compute the transitive eclass closure *before* we iterate over `ebuild.Vars`, and update `ebuild.Vars["INHERITED"]` with the full transitive list (space-separated, sorted, or ordered). Wait, `eclassClosure` should probably return the names in the order Portage expects, but typically just sorted names is fine, or space separated list of the ordered slice. Let's return the `ordered` names as well from `eclassClosure` and set `ebuild.Vars["INHERITED"] = strings.Join(ordered_names, " ")` before sorting `keys`.
Wait, if we sort `keys` earlier, it won't matter as long as we modify `ebuild.Vars["INHERITED"]` *before* we loop over `keys`.
