#!/bin/bash
set -euo pipefail
ebuild_dir="./${ecn}/${epn}"
mkdir -p "$ebuild_dir"
declare -A releaseTypes=()
tags=$(curl -fsS  --header "Accept: application/vnd.github+json" --header "Authorization: Bearer ${GH_TOKEN}" https://api.github.com/repos/${github_owner}/${github_repo}/releases | jq -r '.[]? | select(type=="object" and has("tag_name")) | .tag_name')
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
  releaseType="$(echo "${version}" | sed -n 's/^[^_]\+_\(alpha\|beta\|rc\|p[0-9]*\).*$/\1/p')"
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
      echo "DESCRIPTION=\"${description}\""
      echo "HOMEPAGE=\"${homepage}\""
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
