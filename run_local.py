import subprocess
import os

with open("run_local.sh", "w") as f:
    f.write(r"""#!/bin/bash
export ecn="dev-vcs"
export epn="kgithub-notify"
export github_owner="arran4"
export github_repo="kgithub-notify"
export GITHUB_OUTPUT="out.txt"
export description="A sleek GitHub notification system tray application"
export homepage="https://github.com/arran4/kgithub-notify"
export keywords="~amd64 ~x86"
export PV="dummy"
export P="dummy"
export QTMIN="6.6.2"
export KFMIN="6.0.0"
export MOCK_CURL_FAIL=0
export MOCK_CURL_RESPONSE='[{"tag_name": "v1.0.0", "type": "object"}]'
export GH_TOKEN="dummy"

python3 -c "
import sys, os, re
with open('.github/workflows/dev-vcs-kgithub-notify-update.yaml', 'r') as f:
    lines = f.readlines()
def extract_run(name):
    out = []
    in_step = False
    in_run = False
    for line in lines:
        if name in line:
            in_step = True
            continue
        if in_step:
            if line.startswith('        run: |'):
                in_run = True
                continue
            if in_run:
                if line.startswith('          '):
                    out.append(line[10:])
                elif line.strip() == '':
                    out.append(chr(10))
                else:
                    break
            else:
                if not line.startswith('        '):
                    break
    res = ''.join(out).strip()
    return res

process_script = extract_run('id: process_releases')
process_script = re.sub(r'\$\{\{\s*env\.([A-Za-z0-9_]+)\s*\}\}', r'${\1}', process_script)
process_script = process_script.replace('${{secrets.GITHUB_TOKEN}}', 'dummy')
process_script = process_script.replace('${{ PV }}', '${PV}')
process_script = process_script.replace('${{ P }}', '${P}')
process_script = process_script.replace('${{ QTMIN }}', '${QTMIN}')
process_script = process_script.replace('${{ KFMIN }}', '${KFMIN}')
with open('process_releases.sh', 'w') as f:
    f.write('#!/bin/bash\n' + process_script + '\n')
"
chmod +x process_releases.sh

cat << 'MOCK' > gh
#!/bin/bash
if [[ "$1" == "pr" && "$2" == "list" ]]; then
    head_branch=""
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--head" ]]; then head_branch="$2"; fi
        shift
    done
    if [[ "$head_branch" == "update-kgithub-notify-v1.0.0" || "$head_branch" == "update-kgithub-notify-1.0.0" ]]; then
        echo '[{"number": 100, "state": "OPEN"}]'
    else
        echo '[]'
    fi
fi
MOCK
chmod +x gh

cat << 'MOCK' > curl
#!/bin/bash
echo "$MOCK_CURL_RESPONSE"
MOCK
chmod +x curl
export PATH="$PWD:$PATH"

bash -x ./process_releases.sh > process_out.txt 2>&1
cat process_out.txt
""")

subprocess.run(["bash", "run_local.sh"])
