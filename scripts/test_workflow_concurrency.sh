#!/bin/bash
set -e

# Find all yaml/yml files in .github/workflows
WORKFLOWS=$(find .github/workflows -type f -name "*.yaml" -o -name "*.yml")

# Keep track of errors
ERRORS=0

for WORKFLOW in $WORKFLOWS; do
    # Check for verbatim group: ci-${{ github.ref }}
    if grep -q -E "group: ci-\\\$\{\{ github\.ref \}\}$" "$WORKFLOW"; then
        echo "Error: $WORKFLOW uses overly broad concurrency group"
        ERRORS=$((ERRORS + 1))
    fi
    if grep -q -E "group: ci-\\\$\{\{ github\.ref \}\}\r$" "$WORKFLOW"; then
        echo "Error: $WORKFLOW uses overly broad concurrency group"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ "$ERRORS" -gt 0 ]; then
    echo "Found $ERRORS workflows with overly broad concurrency groups."
    echo "These are generated files pending an upstream fix in arrans_overlay_workflow_builder."
    return 1 2>/dev/null || (kill -s TERM $$)
fi

echo "All workflows have proper concurrency groups."
return 0 2>/dev/null
