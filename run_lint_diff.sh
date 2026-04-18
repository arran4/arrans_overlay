# Extract directories that have changed
dirs=$(git diff --name-only HEAD~1 HEAD | grep -E "^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+/" | cut -d/ -f1,2 | sort -u || true)
if [ -z "$dirs" ]; then
    echo "No package directories modified. Linting passed."
else
    # Lint each modified directory
    exit_code=0
    for dir in $dirs; do
        echo "Linting $dir..."
        g2 lint "$dir" || exit_code=$?
    done
    if [ $exit_code -ne 0 ]; then
        echo "Linting failed"
    fi
fi
