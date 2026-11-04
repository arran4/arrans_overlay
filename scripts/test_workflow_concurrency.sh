#!/bin/bash
set -euo pipefail

MODE="${1:-manual}"
WORKFLOW_DIR="${2:-.github/workflows}"
WORKFLOWS=$(find "$WORKFLOW_DIR" -type f -name "*.yaml" -o -name "*.yml" | sort)
ERRORS=0
GENERATED_ERRORS=0

if [ "$MODE" != "manual" ] && [ "$MODE" != "strict" ]; then
    echo "Invalid mode '$MODE'. Use 'manual' or 'strict'."
    exit 1
fi

for WORKFLOW in $WORKFLOWS; do
    IS_GENERATED=0
    if grep -q "Generated using:" "$WORKFLOW"; then
        IS_GENERATED=1
    fi

    # Check for verbatim group: ci-${{ github.ref }}
    if grep -q -E "group: ci-\\\$\{\{ github\.ref \}\}\$|group: ci-\\\$\{\{ github\.ref \}\}\r\$" "$WORKFLOW"; then
        if [ "$IS_GENERATED" -eq 1 ]; then
            GENERATED_ERRORS=$((GENERATED_ERRORS + 1))
            if [ "$MODE" = "strict" ]; then
                echo "Error (Generated): $WORKFLOW uses overly broad concurrency group"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo "Error (Manual): $WORKFLOW uses overly broad concurrency group"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

if [ "$GENERATED_ERRORS" -gt 0 ]; then
    echo "Inventory: Found $GENERATED_ERRORS generated workflows with overly broad concurrency groups."
    echo "These are pending an upstream fix in arrans_overlay_workflow_builder."
fi

if [ "$ERRORS" -gt 0 ]; then
    echo "Found $ERRORS workflows failing the check."
    exit 1
fi

echo "All checked workflows have proper concurrency groups."
exit 0
