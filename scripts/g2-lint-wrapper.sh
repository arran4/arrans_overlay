#!/bin/bash
OUTPUT=$(g2 lint "$@" 2>&1 || true)
FILTERED=$(echo "$OUTPUT" | grep -v '\[Warning\] Missing md5-cache for ebuild' | grep -v 'linting found errors' || true)

FILTERED=$(echo "$FILTERED" | awk '
/^\[.*\]$/ {
  if (header != "" && content == 1) {
    print header
    print buffer
  }
  header = $0
  buffer = ""
  content = 0
  next
}
{
  if (header != "") {
    if (buffer != "") {
       buffer = buffer "\n" $0
    } else {
       buffer = $0
    }
    if ($0 ~ /[^[:space:]]/) {
        content = 1
    }
  } else {
    print $0
  }
}
END {
  if (header != "" && content == 1) {
    print header
    print buffer
  }
}
')

echo "$FILTERED"
if [ -n "$FILTERED" ] && echo "$FILTERED" | grep -q '\[\(Error\|Warning\)\]'; then
    false
else
    true
fi
