import re

with open('.github/workflows/gui-apps-tuigreet-bin-update.yaml', 'r') as f:
    content = f.read()

# Replace all spaces with spaces and fixing indentation issue on line 63
lines = content.split('\n')
for i, line in enumerate(lines):
    if "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" in line:
        lines[i] = "            <?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    if "<!DOCTYPE pkgmetadata SYSTEM \"http://www.gentoo.org/dtd/metadata.dtd\">" in line:
        lines[i] = "            <!DOCTYPE pkgmetadata SYSTEM \"http://www.gentoo.org/dtd/metadata.dtd\">"
    if "<pkgmetadata>" in line:
        lines[i] = "            <pkgmetadata>"
    if "<upstream>" in line:
        lines[i] = "              <upstream>"
    if "<remote-id type=\"github\">apognu/tuigreet</remote-id>" in line:
        lines[i] = "                <remote-id type=\"github\">apognu/tuigreet</remote-id>"
    if "</upstream>" in line:
        lines[i] = "              </upstream>"
    if "</pkgmetadata>" in line:
        lines[i] = "            </pkgmetadata>"

content = '\n'.join(lines)
with open('.github/workflows/gui-apps-tuigreet-bin-update.yaml', 'w') as f:
    f.write(content)
