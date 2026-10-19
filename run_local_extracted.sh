#!/bin/bash
set -euo pipefail
mkdir -p dev-vcs/kgithub-notify
export GH_TOKEN="dummy"
export github_owner="arran4"
export github_repo="kgithub-notify"
export epn="kgithub-notify"
export ecn="dev-vcs"
export GITHUB_OUTPUT="out.txt"

cat << 'MOCK' > gh
#!/bin/bash
if [[ "$1" == "pr" && "$2" == "list" ]]; then
    head_branch=""
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--head" ]]; then head_branch="$2"; fi
        shift
    done
    if [[ "$head_branch" == "update-kgithub-notify-v1.0.0" || "$head_branch" == "update-kgithub-notify-1.0.0" ]]; then
        echo '[{"number": 100, "state": "OPEN"}]'
    else
        echo '[]'
    fi
fi
MOCK
chmod +x gh

cat << 'MOCK' > curl
#!/bin/bash
echo '[{"tag_name": "v1.0.0", "type": "object"}]'
MOCK
chmod +x curl
export PATH="$PWD:$PATH"

bash -x ./process_releases.sh > debug.txt 2>&1
echo "Exit code: $?"
cat debug.txt
