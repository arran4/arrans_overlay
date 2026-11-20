import glob

for filepath in glob.glob(".github/workflows/*.yaml"):
    with open(filepath, "r") as f:
        content = f.read()

    # The g2 string is actually:
    # "    go install github.com/arran4/g2@latest"
    content = content.replace("    go install github.com/arran4/g2@latest", "    go install github.com/arran4/g2/cmd/g2@latest\n    sudo cp ~/go/bin/g2 /usr/local/bin/g2")

    with open(filepath, "w") as f:
        f.write(content)
