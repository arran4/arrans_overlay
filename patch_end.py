import re

with open('.github/workflows/app-misc-gdu-bin-update.yaml', 'r') as f:
    content = f.read()

orig = """              echo "generated_tag=${tag}" >> $GITHUB_OUTPUT
            fi
          done

      - name: Commit and push changes"""

new = """              echo "generated_tag=${tag}" >> "$GITHUB_OUTPUT"
            fi
          done

      - name: Commit and push changes"""

content = content.replace(orig, new)

with open('.github/workflows/app-misc-gdu-bin-update.yaml', 'w') as f:
    f.write(content)
