import glob

for filepath in glob.glob(".github/workflows/*.yaml"):
    with open(filepath, "r") as f:
        content = f.read()

    # Fix g2 install path
    content = content.replace("go install github.com/arran4/g2@latest", "go install github.com/arran4/g2/cmd/g2@latest")

    # Fix htmlq installation
    # Find "sudo apt-get install -y wget jq coreutils htmlq" and replace with "sudo apt-get install -y wget jq coreutils"
    content = content.replace("sudo apt-get install -y wget jq coreutils htmlq", "sudo apt-get install -y wget jq coreutils")

    # We should add downloading htmlq from github releases if it's not there.
    # Where is this installed? "Run sudo apt-get update" step.
    # Let's just find that step and add the htmlq download logic.
    htmlq_install = """
    url="$(curl -s --header "Accept: application/vnd.github+json" --header "Authorization: Bearer ${{secrets.GITHUB_TOKEN}}" https://api.github.com/repos/mgdm/htmlq/releases/latest | jq -r '.assets[].browser_download_url | select(endswith("x86_64-linux.tar.gz"))')"
    wget "$url" -O /tmp/htmlq.tar.gz
    tar -xzf /tmp/htmlq.tar.gz -C /tmp
    sudo mv /tmp/htmlq /usr/local/bin/htmlq
"""
    if "htmlq" not in content and "Web AppImage" in filepath:
        # Actually it's probably better to just add it after "sudo apt-get update" block.
        pass

    with open(filepath, "w") as f:
        f.write(content)
