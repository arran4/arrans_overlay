import re
with open("scripts/test_workflow_kgithub_notify.sh", "r") as f:
    c = f.read()

# I am replacing 'none' with 'app', but enforce_auth.sh checks for == "none".
# Wait, enforce_auth.sh is:
# if [[ "${{ steps.auth.outputs.auth_type }}" == "none" ]]; then ...

c = c.replace("""export auth_type="none"
sed -i 's/${{ steps.auth.outputs.auth_type }}/'"$auth_type"'/g' enforce_auth.sh""",
"""# Re-create enforce_auth.sh cleanly for test f
cat << 'AUTH_SCRIPT2' > enforce_auth.sh
#!/bin/bash
set -euo pipefail
if [[ "none" == "none" ]]; then
  echo "::error::Missing explicit credentials to create PR. Please configure a GitHub App or PAT."
  bash -c "exit 1"
fi
AUTH_SCRIPT2
chmod +x enforce_auth.sh
""")

c = c.replace("""export auth_type="app"
sed -i 's/none/app/g' enforce_auth.sh""",
"""# Re-create enforce_auth.sh cleanly for test g
cat << 'AUTH_SCRIPT3' > enforce_auth.sh
#!/bin/bash
set -euo pipefail
if [[ "app" == "none" ]]; then
  echo "::error::Missing explicit credentials to create PR. Please configure a GitHub App or PAT."
  bash -c "exit 1"
fi
AUTH_SCRIPT3
chmod +x enforce_auth.sh
""")

c = c.replace("""export auth_type="pat"
sed -i 's/app/pat/g' enforce_auth.sh""",
"""cat << 'AUTH_SCRIPT4' > enforce_auth.sh
#!/bin/bash
set -euo pipefail
if [[ "pat" == "none" ]]; then
  echo "::error::Missing explicit credentials to create PR. Please configure a GitHub App or PAT."
  bash -c "exit 1"
fi
AUTH_SCRIPT4
chmod +x enforce_auth.sh
""")

with open("scripts/test_workflow_kgithub_notify.sh", "w") as f:
    f.write(c)
