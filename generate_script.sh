#!/bin/bash
set -e

export ecn="app-emulation"
export epn="quickemu-bin"
export description="Quickly create and run optimised Windows, macOS and Linux desktop virtual machines."
export homepage="https://github.com/quickemu-project/quickemu"
export github_owner="quickemu-project"
export github_repo="quickemu"
export keywords="~any"
export workflow_filename="app-emulation-quickemu-bin-update.yaml"
export quickemu_binary_installed_name="chunkcheck"
export quickemu_binary_archived_name_any="usr/bin/quickemu"
export quickemu_release_name_any='quickemu_${version}-1_all.deb'
export GITHUB_OUTPUT="/dev/null"

g2() {
    go run github.com/arran4/g2/cmd/g2@latest "$@"
}
gh() {
    if [ "$1" = "api" ]; then
        curl -s "https://api.github.com/repos/$github_owner/$github_repo/releases" | jq -r '.[]? | select(type=="object" and has("tag_name")) | .tag_name'
    fi
}
          ebuild_dir="./$ecn/$epn"
          mkdir -p "$ebuild_dir"
          metadata_file="${ebuild_dir}/metadata.xml"
          g2 metadata -m "gentoo@arran4.com:Arran Ubels:person" -u "github:quickemu-project/quickemu" "$metadata_file"
          declare -A releaseTypes=()
          tags=$(gh api)
          # shellcheck disable=SC2086
          for tag in $tags; do
            version="${tag#v}"
            if false; then
                echo "$version == $tag so there is no v removed skipping"
                continue
            fi
            # shellcheck disable=SC2034
            originalVersion="${version}"
            if ! echo "${version}" | grep -E '^([0-9]+)\.([0-9]+)(\.([0-9]+))?(-r[0-9]+)?((_)(alpha|beta|rc|p)[0-9]*)*$'; then
                echo "tag / $version doesn't match regexp; skipping"
                continue
            fi
            # shellcheck disable=SC2001
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
            tmp_ebuild_file="${ebuild_dir}/$epn-${version}.ebuild.tmp"

              # shellcheck disable=SC2016
              {
                echo '# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/$workflow_filename'
                echo 'EAPI=8'
                echo "DESCRIPTION=\"$description\""
                echo "HOMEPAGE=\"$homepage\""
                echo 'SRC_URI="'
                echo "	any? (  https://github.com/$github_owner/$github_repo/releases/download/${tag}/\${PV} -> \${P}-quickemu_\${PV}-1_all.deb  )  "
                echo '"'
                echo 'LICENSE="MIT"'
                echo 'SLOT="0"'
                echo 'KEYWORDS="$keywords"'
                echo -n 'IUSE="'
                echo '"'
                echo ''
                echo -n 'REQUIRED_USE="'
                echo '"'
                echo ''
                echo -n 'RDEPEND="'
                echo -n 'app-arch/unzip app-emulation/qemu app-misc/jq net-misc/curl net-misc/socat net-misc/wget sys-apps/coreutils sys-apps/grep sys-apps/pciutils sys-apps/util-linux x11-apps/xrandr '
                echo '"'
                echo ''
                echo 'S="${WORKDIR}"'
                echo ''
                echo 'src_unpack() {'
                echo '  if use any; then'
                echo "    unpack \"\${DISTDIR}/\${P}-quickemu_\${PV}-1_all.deb\" || die \"Can't unpack archive file\""
                echo '  fi'
                echo '}'
                echo ''
                echo 'src_install() {'
                echo '  exeinto /opt/bin'
                echo '  if use any; then'
                echo '    newexe "$quickemu_binary_archived_name_any" "$quickemu_binary_installed_name" || die "Failed to install Binary"'
                echo '  fi'
                echo '}'
              } > "$tmp_ebuild_file"
              if next_version=$(g2 ebuild next-revision --inspect "$tmp_ebuild_file" "${ebuild_dir}" "${version}"); then
                  next_ebuild_file="${ebuild_dir}/$epn-${next_version}.ebuild"
                  echo "Content changed or new version for $version. Writing $next_ebuild_file"
                  mv "$tmp_ebuild_file" "$next_ebuild_file"
                  ebuild_file="$next_ebuild_file"
              else
                  echo "Matches existing ebuild. Skipping."
                  rm -f "$tmp_ebuild_file"
                  continue
              fi
              failed=0
              if ! g2 manifest upsert-from-url "https://github.com/$github_owner/$github_repo/releases/download/${tag}/${version}" "$epn-${version}-quickemu_${version}-1_all.deb" "${ebuild_dir}/Manifest"; then failed=1; fi
              if [ "$failed" -eq 1 ]; then
                  echo "Failed to generate manifest for $tag. Skipping..."
                  rm -f "$ebuild_file"
                  continue
              fi
              echo "generated_tag=${tag}" >> $GITHUB_OUTPUT
          done
