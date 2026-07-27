#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$DIR")"

TEST_DATA_DIR="$REPO_ROOT/test_data_txtar"
mkdir -p "$TEST_DATA_DIR"

cat << 'INNER_EOF' > "$TEST_DATA_DIR/test_update_ebuild.txtar"
-- test-env/app-admin/test-bin/test-bin-1.0.ebuild --
# comment
# another
content
-- test-env/app-admin/test-bin/test-bin-1.0-r1.ebuild --
# old
content
-- test-env/app-admin/test-bin/test-bin-1.0-r2.ebuild --
# old2
content
-- test-env/app-admin/test-bin/test-bin-1.0-r3.ebuild --
# new base
content

-- test-env/app-admin/test-bin/test-bin-1.00-r1.ebuild --
# unrelated
content

-- test-env/app-admin/test-bin/test-bin-1.0.1-r1.ebuild --
# unrelated
content
INNER_EOF

cat << 'INNER_EOF' > "$TEST_DATA_DIR/extract.py"
import sys, os
with open(sys.argv[1]) as f: lines = f.readlines()
cf = None
for l in lines:
    if l.startswith('-- ') and l.endswith(' --\n'):
        cf = l[3:-4]
        os.makedirs(os.path.dirname(cf), exist_ok=True)
        open(cf, 'w').close()
    elif cf:
        with open(cf, 'a') as f: f.write(l)
INNER_EOF

cd "$TEST_DATA_DIR"
python3 extract.py test_update_ebuild.txtar

ebuild_dir="test-env/app-admin/test-bin"
env_epn="test-bin"
version="1.0"

new_content=$(
  {
    echo "# Generated via: some_url"
    echo "new content with differences"
  }
)

ebuild_file=$(bash "$DIR/update_ebuild.sh" "$ebuild_dir" "$env_epn" "$version" "$new_content" | grep "^wrote=" | cut -d= -f2)

if [ "$ebuild_file" != "test-env/app-admin/test-bin/test-bin-1.0-r4.ebuild" ]; then
    echo "Test failed: Expected test-bin-1.0-r4.ebuild, got $ebuild_file"
else
    echo "Test passed."
fi

# Cleanup
cd "$REPO_ROOT"
rm -rf "$TEST_DATA_DIR"
