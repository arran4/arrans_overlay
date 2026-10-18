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

    if [[ "$head_branch" == "update-kgithub-notify-v1.0.0" || "$head_branch" == "update-kgithub-notify-1.0" ]]; then
        echo '[{"number": 100, "state": "OPEN"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.1.0_alpha1" || "$head_branch" == "update-kgithub-notify-1.1_alpha1" ]]; then
        echo '[{"number": 101, "state": "CLOSED"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.2.0" || "$head_branch" == "update-kgithub-notify-1.2" ]]; then
        echo '[{"number": 102, "state": "MERGED"}]'
    elif [[ "$head_branch" == "update-kgithub-notify-v1.4.0" || "$head_branch" == "update-kgithub-notify-1.4" ]]; then
        echo "API rate limit exceeded" >&2
        return 1 2>/dev/null || bash -c "exit 1"
    else
        echo '[]'
    fi
else
    return 1 2>/dev/null || bash -c "exit 1"
fi
MOCK_GH
chmod +x bin/gh

cat << 'MOCK_G2' > bin/g2
#!/bin/bash
echo "g2 $*"
MOCK_G2
chmod +x bin/g2

export PATH="$WF_TEST_DIR/bin:$PATH"

cat << 'PRODUCTION_SCRIPT' > process_releases.sh
#!/bin/bash
set -euo pipefail
ebuild_dir="./${ecn}/${epn}"
mkdir -p "$ebuild_dir"
declare -A releaseTypes=()
tags=$(curl -s  --header "Accept: application/vnd.github+json" --header "Authorization: Bearer dummy" https://api.github.com/repos/${github_owner}/${github_repo}/releases | jq -r '.[]? | select(type=="object" and has("tag_name")) | .tag_name')
# shellcheck disable=SC2086
for tag in $tags; do
  version="${tag#v}"
  if [ "${version}" = "${tag}" ]; then
      echo "$version == $tag so there is no v removed skipping"
      continue
  fi
  # shellcheck disable=SC2034
  originalVersion="${version}"
  if ! echo "${version}" | grep -E '^([0-9]+)\.([0-9]+)(\.([0-9]+))?(-r[0-9]+)?((_)(alpha|beta|rc|p)[0-9]*)*$'; then
      echo "tag / $version doesn't match regexp";
      continue;
  fi
  releaseType="$(echo "${version}" | sed -n 's/^[^_]\._\.alpha\.beta\.rc\.p[0-9]*\..*$/\./p')"
  if [[ ! -v releaseTypes[${releaseType:=release}] ]]; then
      if [[ -v releaseTypes[release] ]]; then
        echo "Already have a newer main release: ${releaseTypes[release]}"
        continue
      fi
      releaseTypes[${releaseType:=release}]="${version}"
  else
      echo "Already have a newer ${releaseType:=release} release: ${releaseTypes[${releaseType:=release}]}"
      continue
  fi
  branch_name_tag="update-${epn}-${tag}"
  branch_name_ver="update-${epn}-${version}"

  # Check PRs for this tag
  pr_info=$(gh pr list --head "$branch_name_tag" --state all --json state,number | jq '.[0] // empty')
  if [ -z "$pr_info" ]; then
      pr_info=$(gh pr list --head "$branch_name_ver" --state all --json state,number | jq '.[0] // empty')
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

    # shellcheck disable=SC2016
    {
      echo '# Manually maintained ebuild logic.'
      echo 'EAPI=8'
      echo ''
      echo 'KFMIN=6.0.0'
      echo 'QTMIN=6.6.2'
      echo 'ECM_TEST="true"'
      echo 'inherit ecm'
      echo "DESCRIPTION=\.${description}\."
      echo "HOMEPAGE=\.${homepage}\."
      echo 'SRC_URI="https://github.com/${github_owner}/${github_repo}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"'
      echo ''
      echo 'LICENSE="BSD"'
      echo 'SLOT="0"'
      echo 'KEYWORDS="${keywords}"'
      echo ''
      echo 'RDEPEND="'
      echo '	>=dev-qt/qtbase-${QTMIN}:6[gui,network,widgets,dbus]'
      echo '	>=dev-qt/qtsvg-${QTMIN}:6'
      echo '	>=kde-frameworks/kcoreaddons-${KFMIN}:6'
      echo '	>=kde-frameworks/kconfigwidgets-${KFMIN}:6'
      echo '	>=kde-frameworks/kxmlgui-${KFMIN}:6'
      echo '	>=kde-frameworks/kwallet-${KFMIN}:6'
      echo '	>=kde-frameworks/knotifications-${KFMIN}:6'
      echo '	>=kde-frameworks/ki18n-${KFMIN}:6'
      echo '	dev-libs/qtkeychain:=[qt6(+)]'
      echo '"'
      echo 'DEPEND="${RDEPEND}'
      echo '	test? ( >=dev-qt/qtbase-${QTMIN}:6[test] )'
      echo '"'
      echo 'BDEPEND="'
      echo '	>=kde-frameworks/extra-cmake-modules-${KFMIN}:0'
      echo '	dev-qt/qttools:6[qdbus]'
      echo '"'
    } > $ebuild_file

    # Manifest generation

    g2 manifest upsert-from-url "https://github.com/${github_owner}/${github_repo}/archive/refs/tags/${tag}.tar.gz" "${epn}-${version}.tar.gz" "${ebuild_dir}/Manifest"
    echo "generated_tag=${tag}" >> $GITHUB_OUTPUT
  fi
done
PRODUCTION_SCRIPT
chmod +x process_releases.sh

cat << 'AUTH_SCRIPT' > enforce_auth.sh
#!/bin/bash
set -euo pipefail
if [[ "${{ steps.auth.outputs.auth_type }}" == "none" ]]; then
  echo "::error::Missing explicit credentials to create PR. Please configure a GitHub App or PAT."
  bash -c "exit 1"
fi
AUTH_SCRIPT
chmod +x enforce_auth.sh

echo "=== Test: Open PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.0", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out.txt 2>&1 || true
cat process_out.txt
grep -q "PR #100 for 1.0 already exists (State: OPEN)" process_out.txt

echo "=== Test: Closed PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.1_alpha1", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out.txt 2>&1 || true
cat process_out.txt
grep -q "PR #101 for 1.1_alpha1 is closed-unmerged." process_out.txt

echo "=== Test: Merged PR (should skip) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.2", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out.txt 2>&1 || true
cat process_out.txt
grep -q "PR #102 for 1.2 already exists (State: MERGED)" process_out.txt

echo "=== Test: New PR (should generate) ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.3", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out.txt 2>&1 || true
cat process_out.txt
if ! grep -xq "generated_tag=v1.3" "$GITHUB_OUTPUT"; then
    echo "FAILED: exact generated_tag=v1.3 not found in GITHUB_OUTPUT"
    bash -c "exit 1"
fi

echo "=== Test: No-op missing secrets ==="
export MOCK_CURL_RESPONSE='[]'
rm -f "$GITHUB_OUTPUT"
./process_releases.sh > process_out2.txt 2>&1
if [ -f "$GITHUB_OUTPUT" ] && grep -q "generated_tag" "$GITHUB_OUTPUT"; then
    echo "Generated tag unexpectedly"
    bash -c "exit 1"
fi
echo "No-op successful."

echo "=== Test: New update missing secrets ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.5", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
export auth_type="none"
sed -i 's/${{ steps.auth.outputs.auth_type }}/'"$auth_type"'/g' enforce_auth.sh
./process_releases.sh > /dev/null 2>&1 || true
if ./enforce_auth.sh > auth_out.txt 2>&1; then
    echo "FAILED: enforce_auth.sh should have failed due to missing secrets!"
    bash -c "exit 1"
else
    cat auth_out.txt
    grep -q "Missing explicit credentials to create PR" auth_out.txt
fi

echo "=== Test: Credential selection provided ==="
export auth_type="app"
cat << 'AUTH_SCRIPT2' > enforce_auth.sh
#!/bin/bash
set -euo pipefail
if [[ "${{ steps.auth.outputs.auth_type }}" == "none" ]]; then
  echo "::error::Missing explicit credentials to create PR. Please configure a GitHub App or PAT."
  bash -c "exit 1"
fi
AUTH_SCRIPT2
chmod +x enforce_auth.sh
sed -i 's/${{ steps.auth.outputs.auth_type }}/'"$auth_type"'/g' enforce_auth.sh
./enforce_auth.sh > auth_out2.txt 2>&1
echo "Enforce Auth passed with auth_type=app"

echo "=== Test: Failed GitHub API Request ==="
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.4", "type": "object"}]'
rm -f "$GITHUB_OUTPUT"
if ./process_releases.sh > process_out3.txt 2>&1; then
    echo "FAILED: process_releases.sh should have failed due to API rate limit"
    bash -c "exit 1"
else
    cat process_out3.txt
    grep -q "API rate limit exceeded" process_out3.txt
fi

echo "All tests passed successfully!"
