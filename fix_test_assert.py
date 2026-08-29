with open('.github/scripts/test_determine_packages.py', 'r') as f:
    content = f.read()

# Make sure `usepkg-exclude` check expects `$CP`
if 'assert "TARGET_BINARY_OPTIONS+=(--usepkg-exclude \\"$CP\\")" in workflow' not in content:
    content = content.replace('assert \'"x11-libs/cairo X"\' in workflow', 'assert \'"x11-libs/cairo X"\' in workflow\n    assert "TARGET_BINARY_OPTIONS+=(--usepkg-exclude \\"$CP\\")" in workflow')

with open('.github/scripts/test_determine_packages.py', 'w') as f:
    f.write(content)
