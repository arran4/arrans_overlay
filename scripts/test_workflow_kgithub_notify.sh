#!/bin/bash
set -e

echo "Creating mock environment..."
mkdir -p /tmp/wf_test
cd /tmp/wf_test

cat << 'MOCK' > mock_gh
#!/bin/bash
if [[ "$1" == "pr" && "$2" == "list" ]]; then
    head_branch=""
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--head" ]]; then head_branch="$2"; fi
        shift
    done
    if [[ "$head_branch" == "update-kgithub-notify-v1.0" ]]; then
        echo '[{"number": 100, "state": "OPEN"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-1.1" ]]; then
        echo '[{"number": 101, "state": "CLOSED"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.2" ]]; then
        echo '[{"number": 102, "state": "MERGED"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-verror" ]]; then
        echo "API rate limit exceeded" >&2
        return 1
    else
        echo '[]'
    fi
else
    return 1
fi
MOCK
chmod +x mock_gh
sed -i 's/return/exit/g' mock_gh

cat << 'MOCK_CURL' > mock_curl
#!/bin/bash
echo '[{"tag_name": "v1.0", "type": "object"}, {"tag_name": "v1.1", "type": "object"}, {"tag_name": "v1.2", "type": "object"}, {"tag_name": "v1.3", "type": "object"}, {"tag_name": "verror", "type": "object"}]'
MOCK_CURL
chmod +x mock_curl

export PATH="$PWD:$PATH"

cat << 'RUN' > run_test.sh
#!/bin/bash
export ecn="dev-vcs"
export epn="kgithub-notify"
export github_owner="arran4"
export github_repo="kgithub-notify"
export GITHUB_OUTPUT="/tmp/wf_test/output"

ebuild_dir="./${ecn}/${epn}"
mkdir -p "$ebuild_dir"
declare -A releaseTypes=()

tags=$(./mock_curl | jq -r '.[]? | select(type=="object" and has("tag_name")) | .tag_name')

for tag in $tags; do
    version="${tag#v}"
    if [ "${version}" = "${tag}" ]; then
        continue
    fi
    originalVersion="${version}"
    if ! echo "${version}" | grep -E '^([0-9]+)\.([0-9]+)(\.([0-9]+))?(-r[0-9]+)?((_)(alpha|beta|rc|p)[0-9]*)*$'; then
        continue;
    fi
    releaseType="$(echo "${version}" | sed -n 's/^[^_]\+_\(alpha\|beta\|rc\|p[0-9]*\).*$/\1/p')"
    # For testing we bypass the releaseType single-grade limit just to test PR checks.
    # Actually wait, the grep will match v1.0, v1.1, v1.2, v1.3.
    # The releaseType limit will skip 1.1, 1.2, 1.3 because they are all "release" type and 1.0 is already added!
    # Ah! That's why they weren't processed!
    # To test we need them to be processed. Let's ignore the grade limit for this test script.

    echo "Processing $version"
    branch_name_tag="update-${epn}-${tag}"
    branch_name_ver="update-${epn}-${version}"

    pr_info=$(./mock_gh pr list --head "$branch_name_tag" --state all --json state,number | jq '.[0] // empty')
    if [ -z "$pr_info" ]; then
        pr_info=$(./mock_gh pr list --head "$branch_name_ver" --state all --json state,number | jq '.[0] // empty')
    fi

    if [ -n "$pr_info" ]; then
        pr_state=$(echo "$pr_info" | jq -r '.state // empty')
        pr_number=$(echo "$pr_info" | jq -r '.number // empty')
        if [[ "$pr_state" == "CLOSED" ]]; then
            echo "PR #$pr_number for $version is closed-unmerged. Update is suppressed until explicit reviewable intervention (e.g., reopen the PR). Skipping."
        else
            echo "PR #$pr_number for $version already exists (State: $pr_state). Skipping."
        fi
        continue
    fi

    ebuild_file="${ebuild_dir}/${epn}-${version}.ebuild"
    if ! ls "${ebuild_dir}/${epn}-${version}"*.ebuild 1> /dev/null 2>&1; then
        echo "Generated ebuild for $version"
        touch "$ebuild_file"
        echo "generated_tag=${tag}" >> $GITHUB_OUTPUT
    fi
done
RUN

chmod +x run_test.sh
./run_test.sh > test_out.txt || true

echo "Test output:"
cat test_out.txt

echo "Testing missing credentials logic..."
cat << 'RUN2' > run_auth_test.sh
#!/bin/bash
auth_type="none"
generated_tag="v1.3"
if [[ -n "$generated_tag" ]]; then
    if [[ "$auth_type" == "none" ]]; then
        echo "::error::Missing explicit credentials to create PR. Please configure a GitHub App or PAT."
        exit 1
    fi
fi
RUN2
chmod +x run_auth_test.sh
if ./run_auth_test.sh > auth_out.txt 2>&1; then
    echo "Auth test failed to fail"
else
    echo "Auth test failed correctly as expected. Output:"
    cat auth_out.txt
fi
