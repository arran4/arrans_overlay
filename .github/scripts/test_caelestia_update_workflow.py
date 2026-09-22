#!/usr/bin/env python3
"""Regression checks for the Caelestia updater's PR and cache safeguards."""

from pathlib import Path

workflow = Path(".github/workflows/caelestia-stack-update.yaml").read_text(encoding="utf-8")

# A scheduled rerun must never rebuild an open PR from main and force-push
# away manual packaging fixes. Check before generating files and again before
# handing the branch to create-pull-request.
assert "- name: Preserve active Caelestia update PR" in workflow
assert "- name: Recheck existing update PR" in workflow
pr_lookup = "gh pr list --state open --head update-caelestia-stack --base main --json number --jq 'length'"
assert workflow.count(pr_lookup) == 2
assert "if: steps.existing_pr.outputs.preserve != 'true'" in workflow
assert workflow.count("steps.existing_pr.outputs.preserve != 'true'") >= 5
assert "steps.recheck_pr.outputs.preserve != 'true'" in workflow
assert "cancel-in-progress: false" in workflow

# g2's md5-dict cannot be copied verbatim into metadata/md5-cache: multiline
# dependency values cause g2 lint to fail. Leave canonical cache creation to
# Portage rather than reproducing the Shell 2.5.0 failure on each update.
assert "cp metadata/md5-dict/" not in workflow
assert "g2 cache generate gui-apps/caelestia-shell" in workflow

print("Caelestia updater workflow checks passed")
