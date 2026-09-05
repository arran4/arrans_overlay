#!/bin/bash
gh() {
    if [ "$1" = "api" ]; then
        curl -s "https://api.github.com/repos/quickemu-project/quickemu/releases" | jq -r '.[]? | select(type=="object" and has("tag_name")) | .tag_name'
    fi
}
gh api
