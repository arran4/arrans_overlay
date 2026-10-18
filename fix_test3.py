with open("scripts/test_workflow_kgithub_notify.sh", "r") as f:
    c = f.read()

c = c.replace("import sys", "import sys\nimport os")
c = c.replace("open('$OLDPWD/.github/workflows/dev-vcs-kgithub-notify-update.yaml', 'r')", "open(os.path.join(os.environ['OLDPWD'], '.github/workflows/dev-vcs-kgithub-notify-update.yaml'), 'r')")

with open("scripts/test_workflow_kgithub_notify.sh", "w") as f:
    f.write(c)
