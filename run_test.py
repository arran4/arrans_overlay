import subprocess
import sys

res = subprocess.run(["bash", "scripts/test_workflow_kgithub_notify.sh"], capture_output=True, text=True)
print(res.stdout)
print(res.stderr, file=sys.stderr)
if res.returncode != 0:
    print(f"FAILED WITH CODE {res.returncode}")
