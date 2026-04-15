#!/bin/bash
export PATH=$PWD:$PATH
echo 'echo "Mocking ebuild command: $@"' > ebuild && chmod +x ebuild
for pkg in "acct-group/ollama" "acct-group/systemctl-operators" "acct-user/ollama" "app-admin/polkit-systemd-cups-control" "app-admin/polkit-systemd-docker-control" "app-admin/polkit-systemd-ollama-control" "app-misc/kjules" "dev-vcs/git-credential-with-kwallet" "www-misc/which_browser"; do
    cd $pkg
    rm -f Manifest
    touch Manifest
    cd ../..
done
