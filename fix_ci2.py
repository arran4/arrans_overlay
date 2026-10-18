with open(".github/workflows/workflow-checks.yml", "r") as f:
    c = f.read()

c = c.replace("        run: ./scripts/workflow_m3shapes_pin_test.sh", "        run: |\n          ./scripts/workflow_m3shapes_pin_test.sh\n          bash scripts/test_workflow_kgithub_notify.sh")

with open(".github/workflows/workflow-checks.yml", "w") as f:
    f.write(c)
