with open(".github/workflows/app-misc-ente-auth-appimage-update.yaml", "r") as f:
    content = f.read()

# 1. Fix the find command to avoid prefix collisions
content = content.replace(
    'highest_rev_ebuild=$(find "${ebuild_dir}" -maxdepth 1 -name "${{ env.epn }}-${version}*.ebuild" 2>/dev/null | sort -V | tail -n 1)',
    'highest_rev_ebuild=$(find "${ebuild_dir}" -maxdepth 1 \\( -name "${{ env.epn }}-${version}.ebuild" -o -name "${{ env.epn }}-${version}-r*.ebuild" \\) 2>/dev/null | sort -V | tail -n 1)'
)

# 2. Fix the curl command to follow redirects
content = content.replace(
    "remote_size=$(curl -s --head",
    "remote_size=$(curl -sL --head"
)

# 3. Add logic to remove the old broken ebuild
content = content.replace(
    'ebuild_file="${ebuild_dir}/${{ env.epn }}-${version}${revision_suffix}.ebuild"',
    'ebuild_file="${ebuild_dir}/${{ env.epn }}-${version}${revision_suffix}.ebuild"\n                    rm "$highest_rev_ebuild"'
)

with open(".github/workflows/app-misc-ente-auth-appimage-update.yaml", "w") as f:
    f.write(content)
