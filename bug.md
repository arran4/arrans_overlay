# Bug Report for overlay_workflow_builder_generator

**Issue**: Generated GitHub Actions workflows currently force Node.js actions (like `actions/checkout@v4`) to use Node 20.

**Details**:
The `overlay_workflow_builder_generator` statically generates `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` inside the `env:` block of GitHub Actions workflows. This is causing CI pipelines to fail or trigger deprecation warnings ("Node.js 20 is deprecated...").

**Expected Behavior**:
The generator should either omit the `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` variable altogether for up-to-date actions (like `actions/checkout@v4`), or parameterize its inclusion, because this workaround is no longer required and causes warnings.

**Workaround**:
For now, manual `sed` / `perl` scripts are required to strip this variable out of generated workflows so CI checks pass.
