#!/usr/bin/env bash
set -euo pipefail

root_dir="${1:-.}"
category="media-fonts"
package="font-logos"
upstream_owner="lukas-w"
upstream_repo="font-logos"
package_dir="${root_dir}/${category}/${package}"

api_headers=(
  -H 'Accept: application/vnd.github+json'
  -H 'X-GitHub-Api-Version: 2022-11-28'
)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  api_headers+=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
fi

release_json="$(curl -fsSL "${api_headers[@]}" \
  "https://api.github.com/repos/${upstream_owner}/${upstream_repo}/releases/latest")"
tag="$(jq -r '.tag_name // empty' <<<"${release_json}")"

if [[ ! "${tag}" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  echo "Unsupported or missing upstream release tag: ${tag:-<empty>}" >&2
  exit 1
fi

version="${BASH_REMATCH[1]}"
asset_name="${package}-${version}.zip"
asset_url="$(jq -r --arg name "${asset_name}" '.assets[] | select(.name == $name) | .browser_download_url' <<<"${release_json}" | head -n1)"

if [[ -z "${asset_url}" || "${asset_url}" == "null" ]]; then
  echo "Release ${tag} does not contain ${asset_name}" >&2
  exit 1
fi

mkdir -p "${package_dir}"

metadata_file="${package_dir}/metadata.xml"
if [[ ! -f "${metadata_file}" ]]; then
  cat >"${metadata_file}" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "https://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
    <maintainer type="person">
        <email>gentoo@arran4.com</email>
        <name>Arran Ubels</name>
    </maintainer>
    <upstream>
        <remote-id type="github">lukas-w/font-logos</remote-id>
    </upstream>
</pkgmetadata>
EOF
fi

ebuild_file="${package_dir}/${package}-${version}.ebuild"
changed=false
if [[ ! -f "${ebuild_file}" ]]; then
  cat >"${ebuild_file}" <<'EOF'
# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Icon font containing logos of Linux distributions and open source software"
HOMEPAGE="https://github.com/lukas-w/font-logos"
SRC_URI="https://github.com/lukas-w/font-logos/releases/download/v${PV}/${P}.zip"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~x86"

BDEPEND="app-arch/unzip"

FONT_SUFFIX="ttf"
FONT_S="${S}/assets"

DOCS=( README.md )
EOF

  g2 manifest upsert-from-url "${asset_url}" "${asset_name}" "${package_dir}/Manifest"
  changed=true
elif [[ ! -s "${package_dir}/Manifest" ]]; then
  g2 manifest upsert-from-url "${asset_url}" "${asset_name}" "${package_dir}/Manifest"
  changed=true
fi

echo "font-logos latest release: ${version}"
echo "ebuild: ${ebuild_file}"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    echo "version=${version}"
    echo "tag=${tag}"
    echo "asset_url=${asset_url}"
    echo "ebuild=${ebuild_file}"
    echo "changed=${changed}"
  } >>"${GITHUB_OUTPUT}"
fi
