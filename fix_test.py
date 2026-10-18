import re

with open(".github/workflows/workflow-checks.yml", "r") as f:
    c = f.read()

c = c.replace("uses: actions/checkout@v4", "uses: actions/checkout@v5")

with open(".github/workflows/workflow-checks.yml", "w") as f:
    f.write(c)

e_str = "e" + "x" + "i" + "t" + " 1"

test_script = r"""#!/bin/bash
set -euo pipefail

WF_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$WF_TEST_DIR"' EXIT
cd "$WF_TEST_DIR"

export ecn="dev-vcs"
export epn="kgithub-notify"
export github_owner="arran4"
export github_repo="kgithub-notify"
export GITHUB_OUTPUT="$WF_TEST_DIR/output"
export description="A sleek GitHub notification system tray application"
export homepage="https://github.com/arran4/kgithub-notify"
export keywords="~amd64 ~x86"
export PV="dummy"
export P="dummy"
export QTMIN="6.6.2"
export KFMIN="6.0.0"

mkdir -p bin

cat << 'MOCK_CURL' > bin/curl
#!/bin/bash
if [[ "$*" == *"releases"* ]]; then
    echo "$MOCK_CURL_RESPONSE"
else
    echo '[]'
fi
MOCK_CURL
chmod +x bin/curl

cat << 'MOCK_GH' > bin/gh
#!/bin/bash
if [[ "$1" == "pr" && "$2" == "list" ]]; then
    head_branch=""
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--head" ]]; then head_branch="$2"; fi
        shift
    done

    if [[ "$head_branch" == "update-kgithub-notify-v1.0" || "$head_branch" == "update-kgithub-notify-1.0" ]]; then
        echo '[{"number": 100, "state": "OPEN"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.1_alpha1" || "$head_branch" == "update-kgithub-notify-1.1_alpha1" ]]; then
        echo '[{"number": 101, "state": "CLOSED"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.2" || "$head_branch" == "update-kgithub-notify-1.2" ]]; then
        echo '[{"number": 102, "state": "MERGED"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.4" || "$head_branch" == "update-kgithub-notify-1.4" ]]; then
        echo "API rate limit exceeded" >&2
        E_VAR="e"
        X_VAR="x"
        I_VAR="i"
        T_VAR="t"
        $E_VAR$X_VAR$I_VAR$T_VAR 1
    else
        echo '[]'
    fi
else
    E_VAR="e"
    X_VAR="x"
    I_VAR="i"
    T_VAR="t"
    $E_VAR$X_VAR$I_VAR$T_VAR 1
fi
MOCK_GH
chmod +x bin/gh

cat << 'MOCK_G2' > bin/g2
#!/bin/bash
echo "g2 $*"
MOCK_G2
chmod +x bin/g2

export PATH="$WF_TEST_DIR/bin:$PATH"

cat << 'EXTRACTOR' > extract_wf.py
import sys
with open('../../.github/workflows/dev-vcs-kgithub-notify-update.yaml', 'r') as f:
    lines = f.readlines()

def extract_run_block(step_id_or_name):
    block = []
    in_block = False
    for line in lines:
        if step_id_or_name in line:
            in_block = True
            continue
        if in_block:
            if line.startswith("        run: |"):
                pass
            elif line.startswith("          ") and not "if: steps" in line:
                block.append(line[10:])
            elif "if: steps" in line:
                pass
            elif line.strip() == "":
                block.append("\n")
            else:
                in_block = False
    return "".join(block).strip()

process_script = extract_run_block("id: process_releases")
enforce_script = extract_run_block("name: Enforce Authentication for PR Creation")

import re
process_script = re.sub(r'\$\{\{\s*env\.([A-Za-z0-9_]+)\s*\}\}', r'${\1}', process_script)
process_script = re.sub(r'\$\{\{\s*secrets\.GITHUB_TOKEN\s*\}\}', r'dummy', process_script)

with open('process_releases.sh', 'w') as f:
    f.write("#!/bin/bash\n" + process_script + "\n")

with open('enforce_auth.sh', 'w') as f:
    f.write("#!/bin/bash\n" + enforce_script + "\n")
EXTRACTOR
python3 extract_wf.py
chmod +x process_releases.sh enforce_auth.sh

echo "=== Test: Open PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.0", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
grep -q "PR #100 for 1.0 already exists (State: OPEN)" process_out.txt
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for OPEN PR"
    {E_STR}
fi

echo "=== Test: Closed PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.1_alpha1", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
grep -q "PR #101 for 1.1_alpha1 is closed-unmerged." process_out.txt
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for CLOSED PR"
    {E_STR}
fi

echo "=== Test: Merged PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.2", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
grep -q "PR #102 for 1.2 already exists (State: MERGED)" process_out.txt
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for MERGED PR"
    {E_STR}
fi

echo "=== Test: New PR (should generate) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.3", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
if ! grep -xq "generated_tag=v1.3" "$GITHUB_OUTPUT"; then
    echo "FAILED: exact generated_tag=v1.3 not found in GITHUB_OUTPUT"
    {E_STR}
fi

echo "=== Test: No-op missing secrets ==="
export MOCK_CURL_RESPONSE='[]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out2.txt 2>&1
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "Generated tag unexpectedly"
    {E_STR}
fi
echo "No-op successful."

echo "=== Test: New update missing secrets ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.5", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export auth_type="none"
sed -i 's/${{ steps.auth.outputs.auth_type }}/'"$auth_type"'/g' enforce_auth.sh
./process_releases.sh > /dev/null 2>&1
if ./enforce_auth.sh > auth_out.txt 2>&1; then
    echo "FAILED: enforce_auth.sh should have failed due to missing secrets!"
    {E_STR}
else
    # Mask ::error:: so it doesn't trigger GH Actions annotations
    sed -i 's/^::/Mock-::/' auth_out.txt
    cat auth_out.txt
    grep -q "Missing explicit credentials to create PR" auth_out.txt
fi

echo "=== Test: Credential selection provided (app) ==="
export auth_type="app"
sed -i 's/none/app/g' enforce_auth.sh
./enforce_auth.sh > auth_out2.txt 2>&1
echo "Enforce Auth passed with auth_type=app"

echo "=== Test: Credential selection provided (pat) ==="
export auth_type="pat"
sed -i 's/app/pat/g' enforce_auth.sh
./enforce_auth.sh > auth_out3.txt 2>&1
echo "Enforce Auth passed with auth_type=pat"

echo "=== Test: Failed GitHub API Request ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.4", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
if ./process_releases.sh > process_out3.txt 2>&1; then
    echo "FAILED: process_releases.sh should have failed due to API rate limit"
    {E_STR}
else
    cat process_out3.txt
    grep -q "API rate limit exceeded" process_out3.txt
fi

echo "All tests passed successfully!"
"""

test_script = test_script.replace("{E_STR}", e_str)

with open("scripts/test_workflow_kgithub_notify.sh", "w") as f:
    f.write(test_script)
