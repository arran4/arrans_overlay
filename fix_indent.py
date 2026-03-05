import re

with open('.github/workflows/gui-apps-tuigreet-bin-update.yaml', 'r') as f:
    content = f.read()

# Replace all spaces with spaces and fixing indentation issue on line 63
lines = content.split('\n')
for i, line in enumerate(lines):
    if "run: |" in line and "Process each release" in lines[i-2]:
        lines[i] = "        run: |"

content = '\n'.join(lines)
with open('.github/workflows/gui-apps-tuigreet-bin-update.yaml', 'w') as f:
    f.write(content)
