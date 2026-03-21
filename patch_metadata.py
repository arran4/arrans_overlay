import re

with open('.github/workflows/app-misc-gdu-bin-update.yaml', 'r') as f:
    content = f.read()

orig = """          if [ ! -f "$metadata_file" ]; then
            cat <<EOF > "$metadata_file"
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">
            <pkgmetadata>
              <upstream>
                <remote-id type="github">dundee/gdu</remote-id>
              </upstream>
            </pkgmetadata>
            EOF
          fi"""

new = """          if [ ! -f "$metadata_file" ]; then
            {
              echo '<?xml version="1.0" encoding="UTF-8"?>'
              echo '<!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">'
              echo '<pkgmetadata>'
              echo '	<upstream>'
              echo '		<remote-id type="github">dundee/gdu</remote-id>'
              echo '	</upstream>'
              echo '</pkgmetadata>'
            } > "$metadata_file"
          fi"""

content = content.replace(orig, new)

with open('.github/workflows/app-misc-gdu-bin-update.yaml', 'w') as f:
    f.write(content)
