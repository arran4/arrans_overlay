1. **P0 - Action inputs literal `${epn}`:** Restore `${{ env.epn }}` in the YAML inputs for `peter-evans/create-pull-request@v8`.
2. **Fix `test_workflow_kgithub_notify.sh`:**
   - Ensure the extractor handles the `set -euo pipefail` properly.
   - Run the extracted script via `if ! ./process_releases.sh > out.txt 2>&1; then echo FAILED; fi` to prevent it killing the main script on unexpected failures.
3. **Merge Conflict:** Resolve the git conflict.
4. **PR Description:** Update description explicitly.
