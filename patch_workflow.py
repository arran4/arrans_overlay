with open(".github/workflows/app-misc-ente-auth-appimage-update.yaml", "r") as f:
    content = f.read()

content = content.replace(
    'g2 manifest upsert-from-url "https://github.com/${{ env.github_owner }}/${{ env.github_repo }}/releases/download/${tag}/ente-${tag}-x86_64.AppImage" "${{ env.epn }}-${version}-ente-${tag}-x86_64.AppImage" "${ebuild_dir}/Manifest"',
    'g2 manifest upsert-from-url "https://github.com/${{ env.github_owner }}/${{ env.github_repo }}/releases/download/${tag}/ente-${tag}-x86_64.AppImage" "${{ env.epn }}-${version}${revision_suffix}-ente-${tag}-x86_64.AppImage" "${ebuild_dir}/Manifest"'
)

with open(".github/workflows/app-misc-ente-auth-appimage-update.yaml", "w") as f:
    f.write(content)
