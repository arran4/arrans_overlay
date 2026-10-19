#!/bin/bash
set -euo pipefail

WF_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$WF_TEST_DIR"' EXIT
cd "$WF_TEST_DIR"

export ecn="dev-vcs"
export epn="kgithub-notify"
export github_owner="arran4"
export github_repo="kgithub-notify"
export GITHUB_OUTPUT="$WF_TEST_DIR/output"
export description="A sleek GitHub notification system tray application"
export homepage="https://github.com/arran4/kgithub-notify"
export keywords="~amd64 ~x86"
export PV="dummy"
export P="dummy"
export QTMIN="6.6.2"
export KFMIN="6.0.0"

cat << 'EXTRACTOR' > extract_wf.py
import sys, os, re
with open(os.path.join(os.environ['OLDPWD'], '.github/workflows/dev-vcs-kgithub-notify-update.yaml'), 'r') as f:
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
                if not line.startswith('        ') and not line.strip() == '':
                    break
    res = ''.join(out).strip()
    return res

process_script = extract_run('id: process_releases')
with open('process_releases.sh', 'w') as f:
    f.write('#!/bin/bash\n' + process_script + '\n')
EXTRACTOR

python3 extract_wf.py
chmod +x process_releases.sh
cat process_releases.sh
