import re

with open(".github/workflows/app-emulation-quickemu-bin-update.yaml", "r") as f:
    content = f.read()

# Extract the run block
match = re.search(r"        id: process_releases\n        run: \|\n(.*?)\n      - name: Deduplicate ebuilds", content, re.DOTALL)
if not match:
    print("Could not find the run block")
    exit(1)

run_block = match.group(1)

# Mock environment variables
mock_env = """
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
"""

# Mock g2 commands
mock_g2 = """
g2() {
    go run github.com/arran4/g2/cmd/g2@latest "$@"
}
gh() {
    if [ "$1" = "api" ]; then
        curl -s "https://api.github.com/repos/$github_owner/$github_repo/releases" | jq -r '.[]? | select(type=="object" and has("tag_name")) | .tag_name'
    fi
}
"""

run_block = run_block.replace("${{ env.ecn }}", "$ecn")
run_block = run_block.replace("${{ env.epn }}", "$epn")
run_block = run_block.replace("${{ env.github_owner }}", "$github_owner")
run_block = run_block.replace("${{ env.github_repo }}", "$github_repo")
run_block = run_block.replace("${{ env.description }}", "$description")
run_block = run_block.replace("${{ env.homepage }}", "$homepage")
run_block = run_block.replace("${{ env.workflow_filename }}", "$workflow_filename")
run_block = run_block.replace("${{ env.keywords }}", "$keywords")
run_block = run_block.replace("${{ env.quickemu_binary_archived_name_any }}", "$quickemu_binary_archived_name_any")
run_block = run_block.replace("${{ env.quickemu_binary_installed_name }}", "$quickemu_binary_installed_name")

lines = run_block.split('\n')
for i, line in enumerate(lines):
    if line.strip().startswith('tags='):
        lines[i] = '          tags=$(gh api)'
    elif 'version="${tag#v}"' in line:
        pass # allow versions without v to pass as well for this specific repo
    elif 'if [ "${version}" = "${tag}" ]; then' in line:
        lines[i] = '            if false; then'

run_block = '\n'.join(lines)

# Create script
with open("generate_script.sh", "w") as f:
    f.write("#!/bin/bash\n")
    f.write("set -e\n")
    f.write(mock_env)
    f.write(mock_g2)
    f.write(run_block)

print("Generated script. Running it now...")
