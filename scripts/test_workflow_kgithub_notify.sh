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
    if [[ "$*" == *"-f"* ]] || [[ "$*" == *"--fail"* ]]; then
        echo "curl: (22) The requested URL returned error: 403" >&2
        exit 22
    else
        echo '{"message": "API rate limit exceeded for..."}'
        exit 0
    fi
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

    if [[ "$head_branch" == "update-kgithub-notify-v1.0.0" || "$head_branch" == "update-kgithub-notify-1.0.0" ]]; then
        echo '[{"number": 100, "state": "OPEN"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.1.0_alpha1" || "$head_branch" == "update-kgithub-notify-1.1.0_alpha1" ]]; then
        echo '[{"number": 101, "state": "CLOSED"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.2.0" || "$head_branch" == "update-kgithub-notify-1.2.0" ]]; then
        echo '[{"number": 102, "state": "MERGED"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.4.0" || "$head_branch" == "update-kgithub-notify-1.4.0" ]]; then
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
def extract_run(name):
    out = []
    in_step = False
    in_run = False
    for line in lines:
        if name in line:
            in_step = True
            continue
        if in_step:
            if line.startswith('        run: |'):
                in_run = True
                continue
            if in_run:
                if line.startswith('          '):
                    out.append(line[10:])
                elif line.strip() == '':
                    out.append(chr(10))
                else:
                    break
            else:
                if not line.startswith('        ') and not line.strip() == '':
                    break
    res = ''.join(out).strip()
    return res

process_script = extract_run('id: process_releases')
with open('process_releases.sh', 'w') as f:
    f.write('#!/bin/bash' + chr(10) + process_script + chr(10))

auth_script = extract_run('name: Verify Authentication Setup')
with open('auth_setup.sh', 'w') as f:
    f.write('#!/bin/bash' + chr(10) + auth_script + chr(10))

enforce_script = extract_run('name: Enforce Authentication for PR Creation')
with open('enforce_auth.sh', 'w') as f:
    f.write('#!/bin/bash' + chr(10) + enforce_script + chr(10))

verify_script = extract_run('name: Verify Generated PR')
with open('verify_pr.sh', 'w') as f:
    f.write('#!/bin/bash' + chr(10) + verify_script + chr(10))
EXTRACTOR

python3 extract_wf.py
chmod +x process_releases.sh auth_setup.sh enforce_auth.sh verify_pr.sh

echo "=== Test: Open PR (should skip) ==="
export MOCK_CURL_FAIL=0
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.0.0", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export GH_TOKEN="dummy"
if ! ./process_releases.sh > process_out.txt 2>&1; then
    echo "FAILED: process_releases.sh exited non-zero unexpectedly"
    cat process_out.txt
    exit 1
fi
cat process_out.txt
if ! grep -q "PR #100 for 1.0.0 already exists (State: OPEN)" process_out.txt; then
    echo "FAILED: Did not find skip message in output"
    exit 1
fi
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for OPEN PR"
    exit 1
fi

echo "=== Test: Closed PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.1.0_alpha1", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
if ! ./process_releases.sh > process_out.txt 2>&1; then
    echo "FAILED: process_releases.sh exited non-zero unexpectedly"
    cat process_out.txt
    exit 1
fi
cat process_out.txt
if ! grep -q "PR #101 for 1.1.0_alpha1 is closed-unmerged." process_out.txt; then
    echo "FAILED: Did not find skip message for CLOSED PR"
    exit 1
fi
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for CLOSED PR"
    exit 1
fi

echo "=== Test: Merged PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.2.0", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
if ! ./process_releases.sh > process_out.txt 2>&1; then
    echo "FAILED: process_releases.sh exited non-zero unexpectedly"
    cat process_out.txt
    exit 1
fi
cat process_out.txt
if ! grep -q "PR #102 for 1.2.0 already exists (State: MERGED)" process_out.txt; then
    echo "FAILED: Did not find skip message for MERGED PR"
    exit 1
fi
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "FAILED: generated tag unexpectedly for MERGED PR"
    exit 1
fi

echo "=== Test: New PR (should generate) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.3.0", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
if ! ./process_releases.sh > process_out.txt 2>&1; then
    echo "FAILED: process_releases.sh exited non-zero unexpectedly"
    cat process_out.txt
    exit 1
fi
cat process_out.txt
if ! grep -xq "generated_tag=v1.3.0" "$GITHUB_OUTPUT"; then
    echo "FAILED: exact generated_tag=v1.3.0 not found in GITHUB_OUTPUT"
    exit 1
fi

EBUILD_PATH="${ecn}/${epn}/${epn}-1.3.0.ebuild"
if [ ! -f "$EBUILD_PATH" ]; then
    echo "FAILED: ebuild file not generated at $EBUILD_PATH"
    exit 1
fi

if grep -q "\${github_owner}" "$EBUILD_PATH"; then
    echo "FAILED: ebuild contains literal \${github_owner}"
    exit 1
fi

if grep -q "\${github_repo}" "$EBUILD_PATH"; then
    echo "FAILED: ebuild contains literal \${github_repo}"
    exit 1
fi

if grep -q "\${keywords}" "$EBUILD_PATH"; then
    echo "FAILED: ebuild contains literal \${keywords}"
    exit 1
fi

if ! grep -q 'SRC_URI="https://github.com/arran4/kgithub-notify/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"' "$EBUILD_PATH"; then
    echo "FAILED: ebuild missing exact expected SRC_URI"
    exit 1
fi

if ! grep -q 'KEYWORDS="~amd64 ~x86"' "$EBUILD_PATH"; then
    echo "FAILED: ebuild missing exact expected KEYWORDS"
    exit 1
fi

if ! grep -q 'DESCRIPTION="A sleek GitHub notification system tray application"' "$EBUILD_PATH"; then
    echo "FAILED: ebuild missing exact expected DESCRIPTION"
    exit 1
fi

if ! grep -q 'HOMEPAGE="https://github.com/arran4/kgithub-notify"' "$EBUILD_PATH"; then
    echo "FAILED: ebuild missing exact expected HOMEPAGE"
    exit 1
fi


echo "=== Test: No-op missing secrets ==="
export MOCK_CURL_RESPONSE='[]'
rm -f "$GITHUB_OUTPUT"
if ! ./process_releases.sh > process_out2.txt 2>&1; then
    echo "FAILED: process_releases.sh exited non-zero unexpectedly"
    cat process_out2.txt
    exit 1
fi
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "Generated tag unexpectedly"
    exit 1
fi
echo "No-op successful."

echo "=== Test: Fail closed on invalid GitHub release responses ==="
for response in '{"message":"API rate limit exceeded"}' '[{"name":"missing tag_name"}]' 'null'; do
    export MOCK_CURL_RESPONSE="$response"
    rm -f "$GITHUB_OUTPUT"
    if ./process_releases.sh > api_shape_out.txt 2>&1; then
        echo "FAILED: malformed API response was incorrectly accepted as no updates: $response"
        exit 1
    fi
    if [ -f "$GITHUB_OUTPUT" ] && grep -q '^generated_tag=' "$GITHUB_OUTPUT"; then
        echo "FAILED: malformed API response generated an update"
        exit 1
    fi
done

echo "=== Test: Authentication selection from production Bash ==="
assert_auth_route() {
    local expected="$1" app_id="$2" private_key="$3" pat="$4"
    local output="$WF_TEST_DIR/auth-selection-output"
    rm -f "$output"
    if ! APP_ID="$app_id" APP_PRIVATE_KEY="$private_key" PAT_TOKEN="$pat" \
         GITHUB_OUTPUT="$output" ./auth_setup.sh > auth_selection_out.txt 2>&1; then
        echo "FAILED: auth selector exited nonzero"
        exit 1
    fi
    if [ "$(wc -l < "$output")" -ne 1 ] || ! grep -qx "auth_type=$expected" "$output"; then
        echo "FAILED: expected auth_type=$expected"
        exit 1
    fi
    if grep -Eq 'mock-private-key|mock-pat-token' auth_selection_out.txt; then
        echo "FAILED: authentication secrets appeared in logs"
        exit 1
    fi
}
assert_auth_route none '' '' ''
assert_auth_route app 123 mock-private-key ''
assert_auth_route app 123 mock-private-key mock-pat-token
assert_auth_route pat '' '' mock-pat-token
assert_auth_route pat 123 '' mock-pat-token
assert_auth_route pat '' mock-private-key mock-pat-token
assert_auth_route none 123 '' ''
assert_auth_route none '' mock-private-key ''

echo "=== Test: New update missing secrets ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.5.0", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export AUTH_TYPE="none"
if ! ./process_releases.sh > process_out3.txt 2>&1; then
    echo "FAILED: process_releases.sh exited non-zero unexpectedly"
    cat process_out3.txt
    exit 1
fi
if ! grep -xq "generated_tag=v1.5.0" "$GITHUB_OUTPUT"; then
    echo "FAILED: expected generated_tag=v1.5.0 not found"
    exit 1
fi

if ./enforce_auth.sh > auth_out.txt 2>&1; then
    echo "FAILED: enforce_auth.sh should have failed due to missing secrets!"
    exit 1
else
    # Mask ::error:: so it doesn't trigger GH Actions annotations
    sed -i 's/^::/Mock-::/' auth_out.txt
    if ! grep -q "Missing explicit credentials to create PR" auth_out.txt; then
        cat auth_out.txt
        echo "FAILED: Did not find explicit credentials error"
        exit 1
    fi
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

echo "=== Test: PR creation postcondition ==="
export GITHUB_REPOSITORY=arran4/arrans_overlay
export PR_NUMBER=123
export PR_URL=https://github.com/arran4/arrans_overlay/pull/123
for operation in created updated; do
    PR_OPERATION="$operation" ./verify_pr.sh > verify_out.txt 2>&1 || {
        cat verify_out.txt
        echo "FAILED: $operation should confirm a valid PR"
        exit 1
    }
done
for operation in none closed; do
    if PR_OPERATION="$operation" ./verify_pr.sh > verify_out.txt 2>&1; then
        echo "FAILED: $operation must not count as an update PR"
        exit 1
    fi
done
if PR_NUMBER='' PR_OPERATION=created ./verify_pr.sh > verify_out.txt 2>&1; then
    echo "FAILED: missing PR number must fail"
    exit 1
fi
if PR_URL='' PR_OPERATION=created ./verify_pr.sh > verify_out.txt 2>&1; then
    echo "FAILED: missing PR URL must fail"
    exit 1
fi

echo "=== Test: Failed GitHub API Request (gh command) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.4.0", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
if ./process_releases.sh > process_out3.txt 2>&1; then
    echo "FAILED: process_releases.sh should have failed due to API rate limit"
    exit 1
else
    if ! grep -q "API rate limit exceeded" process_out3.txt; then
        echo "FAILED: API rate limit message not found"
        cat process_out3.txt
        exit 1
    fi
fi

echo "=== Test: Failed GitHub API Request (curl HTTP error) ==="
export MOCK_CURL_FAIL=1
rm -f "$GITHUB_OUTPUT"
if ./process_releases.sh > process_out4.txt 2>&1; then
    echo "FAILED: process_releases.sh should have failed due to curl HTTP error"
    exit 1
else
    if ! grep -q "curl: (22)" process_out4.txt; then
        echo "FAILED: Curl error not found in output"
        cat process_out4.txt
        exit 1
    fi
fi

echo "All tests passed successfully!"
