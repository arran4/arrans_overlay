#!/bin/bash
# Exercise the installed Gentoo package in a disposable stage3 container.
set -euo pipefail

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/raw" "$work/clean"

echo 'Checking installed CLI and policy'
sos --version
python3 - <<'PY'
from sos.policies import load
from sos.policies.distros.gentoo import GentooPolicy

policy = load(probe_runtime=False)
assert isinstance(policy, GentooPolicy), type(policy)
for package in ('portage', 'sos'):
    info = policy.package_manager.pkg_by_name(package)
    assert info and info['version'], (package, info)
print('PASS: Gentoo policy and real installed-package lookup')
PY
echo 'Checking installed configuration and plugin discovery'
test -f /etc/sos/sos.conf
test -d /etc/sos/cleaner
test "$(stat -c '%a' /etc/sos/cleaner)" = 700
test -f /usr/share/bash-completion/completions/sos
test -f /usr/lib/tmpfiles.d/sos.conf
sos report --list-plugins > "$work/plugins"
grep -E '^[[:space:]]*portage[[:space:]]+' "$work/plugins"

# A synthetic marker in the collected world file tests actual obfuscation.
# Restore the original state on exit even though this container is disposable.
world=/var/lib/portage/world
mkdir -p "$(dirname "$world")"
had_world=false
if [[ -f "$world" ]]; then
    cp -p "$world" "$work/world.orig"
    had_world=true
fi
cleanup() {
    if "$had_world"; then
        cp -p "$work/world.orig" "$world"
    else
        rm -f "$world"
    fi
    rm -rf "$work"
}
trap cleanup EXIT
marker=sosciprivatemarker8675309
printf 'app-misc/%s\n' "$marker" >> "$world"

echo 'Collecting raw and cleaned reports'
# Limit the collection to the plugin under test; do not upload or retain
# reports or cleaner mapping files as workflow artifacts.
timeout 180 sos report --batch -o portage --tmp-dir "$work/raw" \
    --compression-type gzip > "$work/raw.log" 2>&1 || {
    tail -n 30 "$work/raw.log"; exit 1;
}
timeout 180 sos report --batch -o portage --tmp-dir "$work/clean" \
    --compression-type gzip --clean --keywords "$marker" --no-update \
    > "$work/clean.log" 2>&1 || {
    tail -n 30 "$work/clean.log"; exit 1;
}
if grep -q 'Unable to obfuscate report' "$work/clean.log"; then
    echo 'SOS cleaner failed'
    exit 1
fi

python3 - "$work" "$marker" <<'PY'
import pathlib
import sys
import tarfile

work = pathlib.Path(sys.argv[1])
marker = sys.argv[2].encode()
for mode in ('raw', 'clean'):
    archives = list((work / mode).glob('*.tar.gz'))
    assert len(archives) == 1, (mode, 'expected one diagnostic archive')
    with tarfile.open(archives[0], 'r:gz') as archive:
        members = {m.name.split('/', 1)[-1]: m for m in archive.getmembers()
                   if m.isfile()}

        def read(name):
            assert name in members, (mode, 'missing archive member', name)
            with archive.extractfile(members[name]) as stream:
                contents = stream.read()
            assert contents, (mode, 'empty archive member', name)
            return contents

        info = read('sos_commands/portage/emerge-info')
        installed = read('sos_commands/portage/installed-packages')
        useflags = read('sos_commands/portage/installed-use-flags')
        profile = read('sos_commands/portage/profile')
        world = read('var/lib/portage/world')
        read('sos_reports/manifest.json')
        assert b'Portage' in info, (mode, 'emerge --info did not work')
        assert b'sys-apps/portage-' in installed, (mode, 'Portage not listed')
        assert b'app-admin/sos-' in installed, (mode, 'installed SOS not listed')
        assert b'sys-apps/portage-' in useflags, (mode, 'USE report lacks packages')
        assert b'profile' in profile.lower(), (mode, 'profile command failed')
        assert (marker in world) == (mode == 'raw'), (mode, 'redaction failed')

print('PASS: installed SOS, Gentoo collector, readable archives and keyword redaction')
PY
