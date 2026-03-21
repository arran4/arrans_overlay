cat << 'EOF2' > patch_end.py
import re

with open('.github/workflows/app-misc-gdu-bin-update.yaml', 'r') as f:
    content = f.read()

# Replace "skip removing v" logic
orig = """            fi
          done"""

print(orig in content)

EOF2
python3 patch_end.py
