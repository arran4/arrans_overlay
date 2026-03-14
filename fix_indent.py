import glob
import re

for filepath in glob.glob(".github/workflows/*.yaml"):
    with open(filepath, "r") as f:
        content = f.read()

    # The metadata.xml heredoc looks like:
    #               cat << 'EOF' > ${ebuild_dir}/metadata.xml
    #               <?xml version="1.0" encoding="UTF-8"?>
    #               ...
    #               EOF
    # We need to make sure the block between the `cat` and `EOF` is properly indented
    # in YAML it needs to be indented more than the command itself, or properly aligned

    # Actually wait. The issue is `could not parse as YAML: could not find expected ':'`
    # Let's see what the block looks like before doing complex things.
    pass
