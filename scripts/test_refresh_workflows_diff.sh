#!/usr/bin/env bash
set -euo pipefail

# Regression: a blank-line -I expression masks *all* differences, including
# executable changes. The refresh workflow must use --ignore-blank-lines.
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
grep -Fq -- "--ignore-blank-lines" "$root/.github/workflows/refresh-workflows.yml"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q
git config user.name 'Workflow test'
git config user.email 'workflow-test@example.invalid'
printf '# old header\nname: Old\n' > sample.yaml
git add sample.yaml
git commit -qm baseline

assert_substantive_diff() {
  local expected="$1" actual=false
  if [[ -n "$(git diff --cached -w --ignore-blank-lines -I '^[[:space:]]*#' -- sample.yaml)" ]]; then
    actual=true
  fi
  if [[ "$actual" != "$expected" ]]; then
    echo "Expected substantive diff=$expected; got $actual" >&2
    git diff --cached -- sample.yaml >&2
    exit 1
  fi
}

printf '# new header\nname: Old\n' > sample.yaml
git add sample.yaml
assert_substantive_diff false

printf '# old header\n\nname: Old\n' > sample.yaml
git add sample.yaml
assert_substantive_diff false

printf '# new header\nname: New\n' > sample.yaml
git add sample.yaml
assert_substantive_diff true

echo 'Refresh workflow diff filtering: PASS'
