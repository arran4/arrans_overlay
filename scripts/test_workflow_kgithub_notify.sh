#!/bin/bash
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
if [[ "$MOCK_CURL_FAIL" == "1" ]]; then
    echo "HTTP error" >&2
    exit 1
fi
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
        exit 1
    else
        echo '[]'
    fi
else
    exit 1
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
import sys, os, re
with open(os.path.join(os.environ['OLDPWD'], '.github/workflows/dev-vcs-kgithub-notify-update.yaml'), 'r') as f:
    lines = f.readlines()
def extract_run_block(step_id_or_name):
    block = []
    in_block = False
    in_run = False
    for line in lines:
        if step_id_or_name in line:
            in_block = True
            continue
        if in_block:
            if line.startswith('        run: |'):
                in_run = True
                continue
            if in_run:
                if line.startswith('          '):
                    block.append(line[10:])
                elif line.strip() == '':
                    block.append(chr(10))
                else:
                    break
            else:
                if not line.startswith('        ') and not line.strip() == '':
                    break
    out = ''.join(block).strip()
    if not out:
        sys.exit(1)
    return out

process_script = extract_run_block('id: process_releases')
enforce_script = extract_run_block('name: Enforce Authentication for PR Creation')

with open('process_releases.sh', 'w') as f:
    f.write('#!/bin/bash' + chr(10) + process_script + chr(10))

with open('enforce_auth.sh', 'w') as f:
    f.write('#!/bin/bash' + chr(10) + enforce_script + chr(10))
EXTRACTOR

python3 extract_wf.py
chmod +x process_releases.sh enforce_auth.sh

echo "=== Test: Open PR (should skip) ==="
export MOCK_CURL_FAIL=0
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.0", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export GH_TOKEN="dummy"
./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
grep -q "PR #100 for 1.0 already exists (State: OPEN)" process_out.txt
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for OPEN PR"
    exit 1
fi

echo "=== Test: Closed PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.1_alpha1", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export GH_TOKEN="dummy"
./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
grep -q "PR #101 for 1.1_alpha1 is closed-unmerged." process_out.txt
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for CLOSED PR"
    exit 1
fi

echo "=== Test: Merged PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.2", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export GH_TOKEN="dummy"
./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
grep -q "PR #102 for 1.2 already exists (State: MERGED)" process_out.txt
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for MERGED PR"
    exit 1
fi

echo "=== Test: New PR (should generate) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.3", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export GH_TOKEN="dummy"
./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
if ! grep -xq "generated_tag=v1.3" "$GITHUB_OUTPUT"; then
    echo "FAILED: exact generated_tag=v1.3 not found in GITHUB_OUTPUT"
    exit 1
fi

echo "=== Test: No-op missing secrets ==="
export MOCK_CURL_RESPONSE='[]'
rm -f "$GITHUB_OUTPUT"
export GH_TOKEN="dummy"
./process_releases.sh > process_out2.txt 2>&1
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "Generated tag unexpectedly"
    exit 1
fi
echo "No-op successful."

echo "=== Test: New update missing secrets ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.5", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export AUTH_TYPE="none"
./process_releases.sh > /dev/null 2>&1
# We assert that generated_tag was set before testing missing auth
if ! grep -xq "generated_tag=v1.5" "$GITHUB_OUTPUT"; then
    echo "FAILED: expected generated_tag=v1.5 not found"
    exit 1
fi

if ./enforce_auth.sh > auth_out.txt 2>&1; then
    echo "FAILED: enforce_auth.sh should have failed due to missing secrets!"
    exit 1
else
    # Mask ::error:: so it doesn't trigger GH Actions annotations
    sed -i 's/^::/Mock-::/' auth_out.txt
    cat auth_out.txt
    grep -q "Missing explicit credentials to create PR" auth_out.txt
fi

echo "=== Test: Credential selection provided (app) ==="
export AUTH_TYPE="app"
if ! ./enforce_auth.sh > auth_out2.txt 2>&1; then
    echo "FAILED: enforce_auth.sh failed when AUTH_TYPE=app"
    cat auth_out2.txt
    exit 1
fi
echo "Enforce Auth passed with AUTH_TYPE=app"

echo "=== Test: Credential selection provided (pat) ==="
export AUTH_TYPE="pat"
if ! ./enforce_auth.sh > auth_out3.txt 2>&1; then
    echo "FAILED: enforce_auth.sh failed when AUTH_TYPE=pat"
    exit 1
fi
echo "Enforce Auth passed with AUTH_TYPE=pat"

echo "=== Test: Failed GitHub API Request (gh command) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.4", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
if ./process_releases.sh > process_out3.txt 2>&1; then
    echo "FAILED: process_releases.sh should have failed due to API rate limit"
    exit 1
else
    cat process_out3.txt
    grep -q "API rate limit exceeded" process_out3.txt
fi

echo "=== Test: Failed GitHub API Request (curl HTTP error) ==="
export MOCK_CURL_FAIL=1
rm -f "$GITHUB_OUTPUT"
if ./process_releases.sh > process_out4.txt 2>&1; then
    echo "FAILED: process_releases.sh should have failed due to curl HTTP error"
    exit 1
else
    cat process_out4.txt
    grep -q "HTTP error" process_out4.txt
fi

echo "All tests passed successfully!"
