with open("scripts/test_workflow_kgithub_notify.sh", "r") as f:
    c = f.read()

c = c.replace("../../.github/workflows/dev-vcs-kgithub-notify-update.yaml", "$OLDPWD/.github/workflows/dev-vcs-kgithub-notify-update.yaml")

with open("scripts/test_workflow_kgithub_notify.sh", "w") as f:
    f.write(c)
