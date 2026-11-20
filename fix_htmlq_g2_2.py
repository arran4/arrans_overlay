import glob
import re

for filepath in glob.glob(".github/workflows/*.yaml"):
    with open(filepath, "r") as f:
        content = f.read()

    # Replace htmlq with the correct download and install block for github runners
    htmlq_block = """    if ! command -v htmlq &> /dev/null; then
      htmlq_url="$(curl -s --header "Accept: application/vnd.github+json" --header "Authorization: Bearer ${{secrets.GITHUB_TOKEN}}" https://api.github.com/repos/mgdm/htmlq/releases/latest | jq -r '.assets[]?.browser_download_url | select(endswith("x86_64-linux.tar.gz"))')"
      if [ -n "$htmlq_url" ]; then
        wget "$htmlq_url" -O /tmp/htmlq.tar.gz
        tar -xzf /tmp/htmlq.tar.gz -C /tmp
        sudo mv /tmp/htmlq /usr/local/bin/htmlq
      fi
    fi
"""
    if "sudo apt-get install -y wget jq coreutils htmlq" in content:
        content = content.replace(
            "sudo apt-get install -y wget jq coreutils htmlq",
            "sudo apt-get install -y wget jq coreutils\n" + htmlq_block
        )

    with open(filepath, "w") as f:
        f.write(content)
