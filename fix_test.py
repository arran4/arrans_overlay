with open('.github/scripts/test_determine_packages.py', 'r') as f:
    content = f.read()

content = content.replace('assert "TARGET_BINARY_OPTIONS+=(--usepkg-exclude \\"$PKG\\")" in workflow', 'assert "TARGET_BINARY_OPTIONS+=(--usepkg-exclude \\"${PKG#=}\\")" in workflow')

with open('.github/scripts/test_determine_packages.py', 'w') as f:
    f.write(content)
