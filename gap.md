## Missing g2 qa-policy.conf support for ignoring rules

The `g2 lint` tool currently has hardcoded behavior for checking MD5 Cache missing (`PG0802`). The `lints/md5cache/md5cache_missing.go` ignores `ignore` values from `metadata/qa-policy.conf` and only allows changing severity to `notice`, `error`, or `warning`:

```go
		if val, ok := qa.Policies["PG0802"]; ok {
			if val == "notice" || val == "error" || val == "warning" {
                // ... sets severity
			}
            // If val == "ignore", it does nothing, severity stays warning!
		}
```

This prevents completely ignoring a rule via policy. It should allow returning early or omitting results if `val == "ignore"`.

As a workaround for `arrans_overlay`, since md5-cache is completely disabled/removed, I have updated `.github/workflows/pr-checks.yml` to use a custom bash wrapper `scripts/g2-lint-wrapper.sh` that filters out the warning and handles the exit code correctly.
