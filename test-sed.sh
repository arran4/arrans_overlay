#!/bin/bash
find /tmp/site_out -type f -name "*.html" -exec sed -i "s|</footer>|<br>Generated on $(date -u +'%Y-%m-%d %H:%M:%S UTC')</footer>|g" {} +
