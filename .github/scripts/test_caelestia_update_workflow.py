#!/usr/bin/env python3
"""Regression checks for the Caelestia updater's branch and cache safeguards."""

from pathlib import Path

workflow = Path(".github/workflows/caelestia-stack-update.yaml").read_text(encoding="utf-8")

# Reuse the fixed branch even while its PR is open. Read current versions from
# that branch so a scheduled run does not regenerate it from main or drop fixes.
checkout = workflow.index("- name: Check out persistent update branch")
versions = workflow.index("- name: Get Latest Upstream Releases")
generate = workflow.index("- name: Update Ebuilds")
commit = workflow.index("- name: Commit and push update safely")
assert checkout < versions < generate < commit
assert 'git switch --create "$BRANCH" "origin/$BRANCH"' in workflow
assert 'git merge-base --is-ancestor HEAD origin/main' in workflow
assert 'git merge --ff-only origin/main' in workflow
assert "if: steps.branch.outputs.skip != 'true'" in workflow
assert "Preserve active Caelestia update PR" not in workflow

# A remote branch update must be a normal fast-forward push; another writer's
# intervening commits must cause a rejected push rather than lost history.
assert 'git push origin "HEAD:refs/heads/$BRANCH"' in workflow
assert "peter-evans/create-pull-request" not in workflow
assert "git push --force" not in workflow
assert "git push -f" not in workflow
assert "git reset --hard" not in workflow
assert "git diff --cached --quiet" in workflow
assert 'gh pr list --state open --head "$BRANCH" --base main' in workflow
assert 'gh pr create --head "$BRANCH" --base main' in workflow

# The generator must create new version files, not overwrite an existing ebuild
# that may have been adjusted while its PR was under review.
assert workflow.count('Refusing to overwrite existing ebuild') == 3

# g2's md5-dict is not an md5-cache file: multiline dependency fields copied
# verbatim into md5-cache caused g2 lint failures on the original update.
assert "cp metadata/md5-dict/" not in workflow
assert "g2 cache generate gui-apps/caelestia-shell" in workflow
assert "cancel-in-progress: false" in workflow

print("Caelestia updater workflow checks passed")
