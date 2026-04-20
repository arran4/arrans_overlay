import os
import sys

def main():
    with open('failed_packages.txt', 'r') as f:
        lines = f.readlines()

    for line in lines:
        if line.startswith('['):
            pkg = line.strip()[1:-1]
            if os.path.isdir(pkg):
                metadata_path = os.path.join(pkg, 'metadata.xml')
                if not os.path.exists(metadata_path):
                    with open(metadata_path, 'w') as mf:
                        mf.write('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "https://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
    <maintainer type="person">
        <email>gentoo@arran4.com</email>
        <name>Arran Ubels</name>
    </maintainer>
</pkgmetadata>
''')
                    print(f"Created {metadata_path}")
                else:
                    # check if maintainer exists
                    with open(metadata_path, 'r') as mf:
                        content = mf.read()
                    if '<maintainer' not in content:
                        print(f"Need to add maintainer to {metadata_path}")
                        # simple inject
                        new_content = content.replace('</pkgmetadata>', '    <maintainer type="person">\n        <email>gentoo@arran4.com</email>\n        <name>Arran Ubels</name>\n    </maintainer>\n</pkgmetadata>')
                        with open(metadata_path, 'w') as mf:
                            mf.write(new_content)
if __name__ == '__main__':
    main()
