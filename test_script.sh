#!/bin/bash
set -e
          curl -sL -A "Mozilla/5.0" https://antigravity.google/download/linux > index.html
          main_js=$(grep -o 'main-[^"]*\.js' index.html | head -n 1 | tr -d '\r')
          echo "main_js: $main_js"
          if [ -z "$main_js" ]; then
            echo "Could not find main_js"
            return 1 2>/dev/null || false
          fi

          curl -sL --compressed -A "Mozilla/5.0" "https://antigravity.google/$main_js" > main.js
          download_url=$(grep -io 'https://[a-zA-Z0-9./_-]*antigravity\.tar\.gz' main.js | head -n 1 | tr -d '\r')
          echo "download_url: $download_url"
          if [ -z "$download_url" ]; then
            echo "Could not find download_url. First 500 bytes of main.js:"
            head -c 500 main.js
            return 1 2>/dev/null || false
          fi
